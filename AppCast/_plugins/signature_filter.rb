module Jekyll
  module SignatureFilter
    def sparkle_signature(release_body)
      regex = /<!-- sparkle:edSignature=(?<signature>.*) -->/m
      signature = release_body.match(regex).named_captures["signature"]
      raise "Didn't find a signature in the release body." if signature.empty?
      signature
    end
  end
end

Liquid::Template.register_filter(Jekyll::SignatureFilter)