require "spec_helper"
require_relative "fixtures/address"
require_relative "fixtures/person"

RSpec.describe Address do
  let(:person1) do
    {
      first_name: "Tom",
      last_name: "Warren",
      age: 40,
      height: 5.8,
      birthdate: Date.new(1980, 2, 15),
      last_login: "1980-02-15T10:00:00Z",
      wakeup_time: "07:30:00",
      active: true,
    }
  end
  let(:person2) do
    {
      first_name: "Jack",
      last_name: "Warren",
      age: 35,
      height: 5.9,
      birthdate: Date.new(1985, 5, 20),
      last_login: "1985-05-20T09:00:00Z",
      wakeup_time: "06:45:00",
      active: false,
    }
  end
  let(:attributes) do
    {
      country: "USA",
      post_code: "01001",
      person: [person1, person2],
    }
  end
  let(:address) { described_class.new(attributes) }

  it "serializes to JSON with a collection of persons" do
    expected_json = {
      country: "USA",
      postCode: "01001",
      person: [
        {
          firstName: "Tom",
          lastName: "Warren",
          age: 40,
          height: 5.8,
          birthdate: "1980-02-15",
          lastLogin: "1980-02-15T10:00:00+00:00",
          wakeupTime: "07:30:00",
          active: true,
        },
        {
          firstName: "Jack",
          lastName: "Warren",
          age: 35,
          height: 5.9,
          birthdate: "1985-05-20",
          lastLogin: "1985-05-20T09:00:00+00:00",
          wakeupTime: "06:45:00",
          active: false,
        },
      ],
    }.to_json

    expect(address.to_json).to eq(expected_json)
  end

  it "deserializes from JSON with a collection of persons" do
    json = {
      country: "USA",
      postCode: "01001",
      person: [
        {
          firstName: "Tom",
          lastName: "Warren",
          age: 40,
          height: 5.8,
          birthdate: "1980-02-15",
          lastLogin: "1980-02-15T10:00:00Z",
          wakeupTime: "07:30:00",
          active: true,
        },
        {
          firstName: "Jack",
          lastName: "Warren",
          age: 35,
          height: 5.9,
          birthdate: "1985-05-20",
          lastLogin: "1985-05-20T09:00:00Z",
          wakeupTime: "06:45:00",
          active: false,
        },
      ],
    }.to_json

    address_from_json = described_class.from_json(json)
    expect(address_from_json.country).to eq("USA")
    expect(address_from_json.post_code).to eq("01001")
    expect(address_from_json.person.first.first_name).to eq("Tom")
    expect(address_from_json.person.last.first_name).to eq("Jack")
    expect(address_from_json.person.last.active).to be(false)
  end

  it "serializes to XML with a collection of persons" do
    expected_xml = <<~XML
      <Address xmlns:p="http://example.com/person" xmlns:nsp1="http://example.com/nsp1">
        <Country>USA</Country>
        <PostCode>01001</PostCode>
        <p:Person>
          <nsp1:FirstName>Tom</nsp1:FirstName>
          <nsp1:LastName>Warren</nsp1:LastName>
          <p:Age>40</p:Age>
          <p:Height>5.8</p:Height>
          <p:Birthdate>1980-02-15</p:Birthdate>
          <p:LastLogin>1980-02-15T10:00:00+00:00</p:LastLogin>
          <p:WakeupTime>07:30:00</p:WakeupTime>
          <p:Active>true</p:Active>
        </p:Person>
        <p:Person>
          <nsp1:FirstName>Jack</nsp1:FirstName>
          <nsp1:LastName>Warren</nsp1:LastName>
          <p:Age>35</p:Age>
          <p:Height>5.9</p:Height>
          <p:Birthdate>1985-05-20</p:Birthdate>
          <p:LastLogin>1985-05-20T09:00:00+00:00</p:LastLogin>
          <p:WakeupTime>06:45:00</p:WakeupTime>
          <p:Active>false</p:Active>
        </p:Person>
      </Address>
    XML

    expect(address.to_xml).to be_equivalent_to(expected_xml)
  end

  it "deserializes from XML with a collection of persons" do
    xml = <<~XML
      <Address xmlns:p="http://example.com/person" xmlns:nsp1="http://example.com/nsp1">
        <Country>USA</Country>
        <PostCode>01001</PostCode>
        <Person>
          <nsp1:FirstName>Tom</nsp1:FirstName>
          <nsp1:LastName>Warren</nsp1:LastName>
          <Age>40</Age>
          <Height>5.8</Height>
          <Birthdate>1980-02-15</Birthdate>
          <LastLogin>1980-02-15T10:00:00Z</LastLogin>
          <WakeupTime>07:30:00</WakeupTime>
          <Active>true</Active>
        </Person>
        <Person>
          <nsp1:FirstName>Jack</nsp1:FirstName>
          <nsp1:LastName>Warren</nsp1:LastName>
          <Age>35</Age>
          <Height>5.9</Height>
          <Birthdate>1985-05-20</Birthdate>
          <LastLogin>1985-05-20T09:00:00Z</LastLogin>
          <WakeupTime>06:45:00</WakeupTime>
          <Active>false</Active>
        </Person>
      </Address>
    XML

    address_from_xml = described_class.from_xml(xml)
    expect(address_from_xml.country).to eq("USA")
    expect(address_from_xml.post_code).to eq("01001")
    expect(address_from_xml.person.first.first_name).to eq("Tom")
    expect(address_from_xml.person.last.first_name).to eq("Jack")
  end
end
