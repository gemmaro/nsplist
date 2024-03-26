require "./spec_helper"

describe NSPlist do
  describe "Crystal standard API" do
    it "can use to_u8 with base 16" do
      'a'.to_u8(base: 16).should eq(0xa)
    end
  end

  describe "version" do
    version = NSPlist::VERSION
    version.should be_a(String)
    # version.should eq("0.1.0")
  end

  describe NSPlist::NSString do
    it "is compared with String" do
      NSPlist::NSString.new("This is a string").should eq("This is a string")
    end
  end

  describe NSPlist::NSData do
    it "is compared with Bytes" do
      NSPlist::NSData.new(Bytes[0x0f, 0xbd, 0x77, 0x71, 0xc2, 0x73, 0x5a, 0xe]).should eq(Bytes[0x0f, 0xbd, 0x77, 0x71, 0xc2, 0x73, 0x5a, 0xe])
    end
  end

  describe NSPlist::NSArray do
    it "can be created from simple array" do
      NSPlist::NSArray.new(["San Francisco", "New York"]).should be_a(NSPlist::NSArray)
    end
  end

  describe NSPlist::NSDictionary do
    it "can be created from simple hash" do
      NSPlist::NSDictionary.new({"user" => "wshakesp", "birth" => "1564"}).should be_a(NSPlist::NSDictionary)
    end
  end

  describe ".parse" do
    it "can parse string" do
      result = NSPlist.parse(%("This is a string"))
      result.should be_a(NSPlist::NSString)
      result.should eq("This is a string")
    end

    it "can parse bare string" do
      result = NSPlist.parse("2plus2is5")
      result.should be_a(NSPlist::NSString)
      result.should eq("2plus2is5")
    end

    it "can parse quoted string with star" do
      result = NSPlist.parse(%("str*ng"))
      result.should be_a(NSPlist::NSString)
      result.should eq("str*ng")
    end

    it "can parse binary data" do
      binary = "<0fbd777 1c2735ae>"
      #          0123456 78901234
      #          0 1 2 3  4 5 6 7
      result = NSPlist.parse(binary)
      result.should be_a(NSPlist::NSData)
      result.should eq(Bytes[0x0f, 0xbd, 0x77, 0x71, 0xc2, 0x73, 0x5a, 0xe])
    end

    it "can parse longer binary data" do
      NSPlist.parse("<9aa5d4cd0403c2d990262c15884181da5d1e32ae>").should be_a(NSPlist::NSData)
    end

    it "can parse array" do
      expected = NSPlist::NSArray.new(["San Francisco", "New York"])
      result = NSPlist.parse(%{("San Francisco", "New York")})
      result.should be_a(NSPlist::NSArray)
      result.should eq(expected)
    end

    it "can parse dictionary" do
      expected = NSPlist::NSDictionary.new({"user" => "wshakesp", "birth" => "1564"})
      result = NSPlist.parse(%({ user = wshakesp; birth = 1564; }))
      result.should be_a(NSPlist::NSDictionary)
      result.should eq(expected)
    end

    it "can parse dictionary, part 2" do
      NSPlist.parse("{ pig = piggish; lamb = lambish; worm = wormy; }").should be_a(NSPlist::NSDictionary)
    end

    it "can parse dictionary of multiple lines" do
      NSPlist.parse(%[{ pig = oink; lamb = baa; worm = baa;
                        Lisa = "Why is the worm talking like a lamb?"; }]).should be_a(NSPlist::NSDictionary)
    end

    it "can parse complex dictionary" do
      NSPlist.parse(%[{
    AnimalSmells = { pig = piggish; lamb = lambish; worm = wormy; };
    AnimalSounds = { pig = oink; lamb = baa; worm = baa;
                    Lisa = "Why is the worm talking like a lamb?"; };
    AnimalColors = { pig = pink; lamb = black; worm = pink; };
}]).should be_a(NSPlist::NSDictionary)
    end

    it "can parse dictionary with tabs" do
      NSPlist.parse("{
	boolean = YES;
	integer = 42;
	real = 3.14;
}").should be_a(NSPlist::NSDictionary)
    end

    it "can parse comment" do
      NSPlist.parse("/* some * text / here */{ key = value; }").should be_a(NSPlist::NSDictionary)
    end
  end
end
