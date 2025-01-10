require "spec_helper"
require_relative "fixtures/person"

RSpec.describe Person do
  let(:attributes) do
    {
      first_name: "John",
      last_name: "Doe",
      age: 30,
      height: 5.9,
      birthdate: "1990-01-01",
      last_login: "2023-06-08T10:00:00+00:00",
      wakeup_time: "07:00:00",
      active: true,
    }
  end

  let(:model) { described_class.new(attributes) }

  let(:attributes_yaml) do
    {
      "firstName" => "John",
      "lastName" => "Doe",
      "age" => 30,
      "height" => 5.9,
      "birthdate" => "1990-01-01",
      "lastLogin" => "2023-06-08T10:00:00+00:00",
      "wakeupTime" => "07:00:00",
      "active" => true,
    }
  end
  let(:attributes_json) do
    {
      firstName: "John",
      lastName: "Doe",
      age: 30,
      height: 5.9,
      birthdate: "1990-01-01",
      lastLogin: "2023-06-08T10:00:00+00:00",
      wakeupTime: "07:00:00",
      active: true,
    }
  end

  it "serializes to XML" do
    expected_xml = <<~XML
      <p:Person xmlns:p="http://example.com/person" xmlns:nsp1="http://example.com/nsp1">
        <nsp1:FirstName>John</nsp1:FirstName>
        <nsp1:LastName>Doe</nsp1:LastName>
        <p:Age>30</p:Age>
        <p:Height>5.9</p:Height>
        <p:Birthdate>1990-01-01</p:Birthdate>
        <p:LastLogin>2023-06-08T10:00:00+00:00</p:LastLogin>
        <p:WakeupTime>07:00:00</p:WakeupTime>
        <p:Active>true</p:Active>
      </p:Person>
    XML

    expect(model.to_xml).to be_equivalent_to(expected_xml)
  end

  it "deserializes from XML" do
    xml = <<~XML
      <p:Person xmlns:p="http://example.com/person" xmlns:nsp1="http://example.com/nsp1">
        <nsp1:FirstName>John</nsp1:FirstName>
        <nsp1:LastName>Doe</nsp1:LastName>
        <p:Age>30</p:Age>
        <p:Height>5.9</p:Height>
        <p:Birthdate>1990-01-01</p:Birthdate>
        <p:LastLogin>2023-06-08T10:00:00+00:00</p:LastLogin>
        <p:WakeupTime>07:00:00</p:WakeupTime>
        <p:Active>true</p:Active>
      </p:Person>
    XML

    person = described_class.from_xml(xml)
    expect(person.first_name).to eq("John")
    expect(person.age).to eq(30)
    expect(person.height).to eq(5.9)
    expect(person.birthdate).to eq(Date.parse("1990-01-01"))
    expect(person.last_login).to eq(DateTime.parse("2023-06-08T10:00:00+00:00"))
    expect(person.wakeup_time).to eq(Time.parse("07:00:00"))
    expect(person.active).to be true
  end

  it "serializes to JSON" do
    expect(model.to_json).to eq(attributes_json.to_json)
  end

  it "deserializes from JSON" do
    json = attributes_json.to_json
    person = described_class.from_json(json)
    expect(person.first_name).to eq("John")
    expect(person.age).to eq(30)
    expect(person.height).to eq(5.9)
    expect(person.birthdate).to eq(Date.parse("1990-01-01"))
    expect(person.last_login).to eq(DateTime.parse("2023-06-08T10:00:00+00:00"))
    expect(person.wakeup_time).to eq(Time.parse("07:00:00"))
    expect(person.active).to be true
  end

  it "deserializes from JSON array" do
    json = [attributes_json.dup, attributes_json.dup].to_json

    persons = described_class.from_json(json)

    expect(persons[0].first_name).to eq("John")
    expect(persons[0].age).to eq(30)
    expect(persons[0].height).to eq(5.9)
    expect(persons[0].birthdate).to eq(Date.parse("1990-01-01"))
    expect(persons[0].last_login).to eq(DateTime.parse("2023-06-08T10:00:00+00:00"))
    expect(persons[0].wakeup_time).to eq(Time.parse("07:00:00"))
    expect(persons[0].active).to be true

    expect(persons[1].first_name).to eq("John")
    expect(persons[1].age).to eq(30)
    expect(persons[1].height).to eq(5.9)
    expect(persons[1].birthdate).to eq(Date.parse("1990-01-01"))
    expect(persons[1].last_login).to eq(DateTime.parse("2023-06-08T10:00:00+00:00"))
    expect(persons[1].wakeup_time).to eq(Time.parse("07:00:00"))
    expect(persons[1].active).to be true
  end

  it "serializes to YAML" do
    expect(model.to_yaml).to eq(attributes_yaml.to_yaml)
  end

  it "deserializes from YAML" do
    yaml = attributes_yaml.to_yaml
    person = described_class.from_yaml(yaml)
    expect(person.first_name).to eq("John")
    expect(person.age).to eq(30)
    expect(person.height).to eq(5.9)
    expect(person.birthdate).to eq(Date.parse("1990-01-01"))
    expect(person.last_login).to eq(DateTime.parse("2023-06-08T10:00:00+00:00"))
    expect(person.wakeup_time).to eq(Time.parse("07:00:00"))
    expect(person.active).to be true
  end

  it "deserializes from YAML array" do
    yaml = [attributes_yaml.dup, attributes_yaml.dup].to_yaml

    persons = described_class.from_yaml(yaml)

    expect(persons[0].first_name).to eq("John")
    expect(persons[0].age).to eq(30)
    expect(persons[0].height).to eq(5.9)
    expect(persons[0].birthdate).to eq(Date.parse("1990-01-01"))
    expect(persons[0].last_login).to eq(DateTime.parse("2023-06-08T10:00:00+00:00"))
    expect(persons[0].wakeup_time).to eq(Time.parse("07:00:00"))
    expect(persons[0].active).to be true

    expect(persons[1].first_name).to eq("John")
    expect(persons[1].age).to eq(30)
    expect(persons[1].height).to eq(5.9)
    expect(persons[1].birthdate).to eq(Date.parse("1990-01-01"))
    expect(persons[1].last_login).to eq(DateTime.parse("2023-06-08T10:00:00+00:00"))
    expect(persons[1].wakeup_time).to eq(Time.parse("07:00:00"))
    expect(persons[1].active).to be true
  end
end
