require 'spec_helper'
require 'swagger/docs/slash_trimmer'

RSpec.describe Swagger::Docs::SlashTrimmer do
  subject(:trimmer) { described_class }

  it "trims leading slashes" do
    expect(trimmer.trim_leading_slashes('///string')).to eq('string')
  end

  it "trims trailing slashes" do
    expect(trimmer.trim_trailing_slashes('string///')).to eq('string')
  end

  it "trims leading and trailing slashes at once" do
    expect(trimmer.trim_slashes('///string///')).to eq('string')
  end
end
