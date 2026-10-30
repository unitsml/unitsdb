# frozen_string_literal: true

# IEC 62720 (openCDD) UnitsML conversion importer — unitsdb#134.
#
# Reads the openCDD database.json, extracts raw_properties.C0105 UnitsML
# payloads, resolves subjects and initialUnits against this register
# (SI Digital Framework reference URIs, alias seeds, name/symbol match),
# cross-validates factors against canonical_conversion, and:
#   - writes reports/iec-62720/coverage.json (+ .md summary): every
#     conversion marked mapped / imported / agreed / disagree / unmapped+reason
#   - imports canonical_conversion ONLY for register units that lack one
#     and whose initialUnit anchors to a canonical register unit, appending
#     an informative iec-62720 reference for provenance
#
# Usage: ruby scripts/import_iec62720.rb <database.json> [unitsdb-root=.]

require "json"
require "yaml"
require "rexml/document"
require "pathname"

CORPUS = ARGV[0] || "/Users/mulgogi/src/opencdd/data-private/data/iec-62720/database.json"
ROOT = Pathname.new(__dir__).join("..").expand_path

failures = []

def rat(str)
  s = str.to_s
  return Rational(s.to_i) if s.match?(/\A-?\d+\z/)
  return Rational(*s.split("/").map(&:to_i)) if s.match?(%r{\A-?\d+/\d+\z})
  Rational(s)
end

# ---- register ---------------------------------------------------------------
units = YAML.load_file(ROOT.join("units.yaml").to_s)["units"]
by_nist = {}
by_name = Hash.new { |h, k| h[k] = [] }
by_ref_uri = {}
units.each do |u|
  id = (u["identifiers"].find { |i| i["type"] == "nist" } || u["identifiers"].first)&.fetch("id")
  by_nist[id] = u if id
  (u["names"] || []).each { |n| by_name[n["value"].downcase] << u if n["lang"] == "en" }
  (u["symbols"] || []).each { |s| by_name[s["id"].downcase] << u }
  (u["references"] || []).each do |r|
    by_ref_uri[r["uri"]] = u if r["uri"]
  end
end
by_name.each_value(&:uniq!)

resolve_name = lambda do |name|
  cands = by_name[name.to_s.downcase]
  return nil, "ambiguous (#{cands.size} register matches: #{cands.map { |c| c['symbols']&.first&.fetch('id', '?') }.join('/')})" if cands.size > 1
  return nil, "no register counterpart" if cands.empty?
  [cands.first, nil]
end

resolve_uri = lambda do |uri|
  u = by_ref_uri[uri]
  u ? [u, nil] : nil
end

# IRDI seeds verified against the corpus (2026-10-30).
IRDI_SEED = {
  "0112/2///62720#UAA000" => "one", # unity
  "0112/2///62720#UAA033" => "degC",
  "0112/2///62720#UAA185" => "K",
  "0112/2///62720#UAA726" => "m",
}.freeze
resolve_irdi = lambda do |irdi|
  short = IRDI_SEED[irdi]
  return nil unless short
  u = units.find { |x| (x["symbols"] || []).any? { |s| s["id"] == short } }
  u ? [u, nil] : nil
end

resolve_unit = lambda do |ref|
  if ref.start_with?("http", "https")
    r = resolve_uri.call(ref)
    return r if r
  end
  r = resolve_irdi.call(ref)
  return r if r
  name = ref.split("#").last&.tr("_", " ")&.downcase
  r = resolve_name.call(name)
  return r if r
  nil
end

# ---- parse corpus ------------------------------------------------------------
corpus = JSON.parse(File.read(CORPUS))
entries = []
malformed_attrs = 0
unsupported = 0
corpus.each do |e|
  payload = e.dig("raw_properties", "C0105")
  next unless payload
  doc = REXML::Document.new(payload.to_s)
  subject_irdi = e["irdi"]
  subject_name = e["preferred_name"] || e["short_name"]
  doc.elements.each("//Unit") do |unit_el|
    subject_ref = unit_el.attributes["xml:id"]
    unit_el.elements.each("Conversions/Float64ConversionFrom") do |cf|
      a = cf.attributes["initialAddend"] || cf.attributes["initialaddend"] || "0"
      b = cf.attributes["multiplicand"] || "1"
      c = cf.attributes["divisor"] || "1"
      d = cf.attributes["finalAddend"] || cf.attributes["finaladdend"] || "0"
      malformed_attrs += 1 if cf.attributes["finaladdend"] && cf.attributes["finalAddend"]
      entries << {
        subject_irdi: subject_irdi, subject_name: subject_name,
        subject_ref: subject_ref, initial: cf.attributes["initialUnit"],
        a: a, b: b, c: c, d: d,
        exact: cf.attributes["exact"] == "true",
      }
    end
    unsupported += unit_el.elements.count("Conversions/SpecialConversionFrom")
    unsupported += unit_el.elements.count("Conversions/WSDLConversionFrom")
  end
end

# ---- resolve + compare + import ---------------------------------------------
def agree?(ours, theirs)
  delta = (rat(ours) - rat(theirs)).abs
  delta == 0 || delta <= rat(ours).abs / Rational(10**9)
end

report = []
imported = 0
entries.each do |e|
  subj, sreason =
    if e[:subject_ref].to_s.start_with?("http")
      resolve_uri.call(e[:subject_ref]) || resolve_name.call(e[:subject_name].to_s.downcase)
    else
      resolve_irdi.call(e[:subject_ref]) || resolve_name.call(e[:subject_name].to_s.downcase)
    end
  ini, ireason = resolve_unit.call(e[:initial])

  rec = {
    subject: "#{e[:subject_name]} (#{e[:subject_ref]})",
    initial: e[:initial], exact: e[:exact],
    factor_theirs: (rat(e[:b]) / rat(e[:c])).to_s,
    offset_theirs: (rat(e[:d]) + rat(e[:b]) / rat(e[:c]) * rat(e[:a])).to_s,
  }

  if subj.nil?
    rec[:status] = "unmapped-subject"; rec[:reason] = sreason
  elsif ini.nil?
    rec[:status] = "unmapped-initial"; rec[:reason] = ireason
  else
    rec[:subject_id] = (subj["identifiers"].find { |i| i["type"] == "nist" } || subj["identifiers"].first)["id"]
    rec[:initial_id] = (ini["identifiers"].find { |i| i["type"] == "nist" } || ini["identifiers"].first)["id"]
    # A corpus conversion "subject Y FROM initial X" is X's canonical form
    # when Y is X's canonical anchor — compare against X's canonical first;
    # only compare against Y's own canonical when X carries none.
    compare = ini["canonical_conversion"] ? ini : subj
    if compare["canonical_conversion"]
      factor_theirs = rat(e[:b]) / rat(e[:c])
      offset_theirs = rat(e[:d]) + factor_theirs * rat(e[:a])
      ours_f = rat(compare.dig("canonical_conversion", "factor") || "1")
      ours_o = rat(compare.dig("canonical_conversion", "offset") || "0")
      if agree?(ours_f, factor_theirs) && agree?(ours_o, offset_theirs)
        rec[:status] = "agreed"
        rec[:compared_against] = compare.equal?(ini) ? "initial" : "subject"
      else
        rec[:status] = "disagree"
        rec[:compared_against] = compare.equal?(ini) ? "initial" : "subject"
        rec[:factor_ours] = ours_f.to_s; rec[:offset_ours] = ours_o.to_s
      end
    elsif ini["canonical_conversion"].nil? &&
          ini["unit_system_reference"].to_a.none? { |s| s["id"].to_s.tr("-", "_").downcase == "si_base" }
      rec[:status] = "unmapped-anchor"; rec[:reason] = "initialUnit has no canonical anchor"
    else
      factor = rat(e[:b]) / rat(e[:c])
      offset = rat(e[:d]) + factor * rat(e[:a])
      cc = { "factor" => factor.to_s }
      cc["offset"] = offset.to_s unless offset.zero?
      ru = ini.dig("canonical_conversion", "root_units") || []
      cc["root_units"] = ru unless ru.empty?
      subj["canonical_conversion"] = cc
      (subj["references"] ||= []) << {
        "type" => "informative", "authority" => "iec-62720",
        "uri" => "https://eci-io.github.io/eci-62720/#{e[:subject_irdi]}",
      }
      imported += 1
      rec[:status] = "imported"
      rec[:factor_imported] = factor.to_s
      rec[:offset_imported] = offset.zero? ? nil : offset.to_s
    end
  end
  report << rec
end

# ---- write -------------------------------------------------------------------
out_dir = ROOT.join("reports", "iec-62720")
out_dir.mkpath
File.write(out_dir.join("coverage.json"), JSON.pretty_generate({
  corpus: CORPUS, entities: corpus.length, conversions: entries.length,
  malformed_duplicate_attributes: malformed_attrs,
  unsupported_nonlinear: unsupported,
  summary: report.group_by { |r| r[:status] }.transform_values(&:count),
  entries: report,
}))

agree = report.count { |r| r[:status] == "agreed" }
dis = report.select { |r| r[:status] == "disagree" }
md = +"# IEC 62720 conversion corpus — coverage report\n\n"
md << "Corpus: #{corpus.length} entities, #{entries.length} Float64ConversionFrom conversions parsed (#{malformed_attrs} duplicate-attribute defects, #{unsupported} non-linear conversions reported as unsupported).\n\n"
md << "| status | count |\n|---|---|\n"
report.group_by { |r| r[:status] }.sort.each { |k, v| md << "| #{k} | #{v.size} |\n" }
md << "\n## Disagreements with the register\n\n"
dis.each { |r| md << "- #{r[:subject]}: theirs factor #{r[:factor_theirs]} vs ours #{r[:factor_ours]}\n" }
File.write(out_dir.join("coverage.md"), md)

puts "conversions: #{entries.length}, imported: #{imported}, agreed: #{agree}, disagree: #{dis.size}, report: #{out_dir}"
unless failures.empty?
  warn failures.join("\n")
  exit 1
end
