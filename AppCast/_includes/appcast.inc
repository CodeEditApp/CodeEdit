<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
        <title>{{ site.github.project_title }}</title>
        <description>Most recent changes with links to updates.</description>
        <language>en</language>
        {% for release in site.github.releases %}
            {% unless release.draft %}
                {% unless release.prerelease and page.release_only %}
                    <item>
                        <title>{{ release.name }}</title>
                        <description><![CDATA[{{ release.body | markdownify }}]]></description>
                        <pubDate>{{ release.published_at | date_to_rfc822 }}</pubDate>
                        {% for asset in release.assets limit:1 %}
                            {% assign signature = release.body | sparkle_signature %}

                            {% assign build_nums = release.tag_name | replace_first:'v','' | replace_first:'b',',' | split:',' %}
                            {% if build_nums.size == 2 %}
                                {% assign version_number = build_nums[0] %}
                                {% assign build_number = build_nums[1] %}

                                <enclosure
                                    url="{{ asset.browser_download_url }}"
                                    sparkle:version="{{ build_number }}"
                                    sparkle:shortVersionString="{{ version_number }}"
                                    sparkle:edSignature="{{ signature }}"
                                    length="{{ asset.size }}"
                                    type="application/octet-stream" />
                            {% else %}
                                {% assign version = release.tag_name | remove_first:'v' %}

                                <enclosure
                                    url="{{ asset.browser_download_url }}"
                                    sparkle:version="{{ version }}"
                                    sparkle:edSignature="{{ signature }}"
                                    length="{{ asset.size }}"
                                    type="application/octet-stream" />
                            {% endif %}
                        {% endfor %}
                    </item>
                {% endunless %}
            {% endunless %}
        {% endfor %}
    </channel>
</rss>
