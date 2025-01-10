module Plurimath
  module Math
    module Symbols
      class Times < Symbol
        INPUT = {
          unicodemath: [["times", "&#xd7;", "&times;"], parsing_wrapper(["xx"], lang: :unicode)],
          asciimath: ["times", "xx", "&#xd7;", "&times;"],
          mathml: ["&#xd7;", "&times;"],
          latex: [["times", "&#xd7;", "&times;"], parsing_wrapper(["xx"], lang: :latex)],
          omml: ["&#xd7;", "&times;"],
          html: ["&#xd7;", "&times;"],
        }.freeze

        # output methods
        def to_latex(**)
          "\\times"
        end

        def to_asciimath(**)
          "xx"
        end

        def to_unicodemath(**)
          Utility.html_entity_to_unicode("&#xd7;")
        end

        def to_mathml_without_math_tag(_, **)
          ox_element("mo") << "&#xd7;"
        end

        def to_omml_without_math_tag(_, **)
          "&#xd7;"
        end

        def to_html(**)
          "&#xd7;"
        end
      end
    end
  end
end
