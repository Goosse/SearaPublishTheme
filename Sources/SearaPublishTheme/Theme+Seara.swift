/**
 *  Publish
 *  Copyright (c) John Sundell 2019
 *  MIT license, see LICENSE file for details
 */

import Plot
import Publish
import Files

public extension Theme {
    
    ///  Custom theme for radioseara.fm
    static var seara: Self {
        Theme(
            htmlFactory: SearaHTMLFactory(),
            resourcePaths: ["Resources/SearaTheme/styles.css", "Resources/SearaTheme/playerScript.js"]
        )
    }
}

private struct SearaHTMLFactory<Site: Website>: HTMLFactory {
    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: index, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .h1(.text(index.title)),
                    .p(
                        .class("description"),
                        .text(context.site.description)
                    ),
                    .h2("Nossos programas"),
                    .sectionListWithAddedPages(for: context.sections, and: [context.pages[Path("ao-vivo")]!])
                    //                    .sectionList
                    //                    .sectionList  (for: context.sections)
                ),
                .footer(for: context.site)
            )
        )
    }
    
    func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site),
            .body(
                .header(for: context, selectedSection: section.id),
                .wrapper(
                    .h1(.text(section.title)),
                    .itemList(for: section.items, on: context.site)
                ),
                .footer(for: context.site)
            )
        )
    }
    
    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site),
            .body(
                .class("item-page"),
                .header(for: context, selectedSection: item.sectionID),
                .wrapper(
                    .article(
                        .div(
                            .class("content"),
                            .contentBody(item.body)
                        ),
                        .span("Tagged with: "),
                        .tagList(for: item, on: context.site)
                    )
                ),
                .footer(for: context.site)
            )
        )
    }
    
    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        if page.path == "ao-vivo" {
            return try makePlayerHTML(for: page, context: context)
        }
        
        
        return HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site)   ,
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(.contentBody(page.body)),
                .footer(for: context.site)
            )
        )
    }
    
    
    
    func makePlayerHTML(for page: Page,
                        context: PublishingContext<Site>) throws -> HTML {
        return HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(.unwrap(page.audio, { .searaPlayer(for: $0, artworkSrc: Path("/recursos/missingArtwork.jpg")) }),
                         .contentBody(page.body)),
                .footer(for: context.site),
                .script(.src("/playerScript.js"))
            )
        )
    }
    
    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .h1("Browse all tags"),
                    .ul(
                        .class("all-tags"),
                        .forEach(page.tags.sorted()) { tag in
                            .li(
                                .class("tag"),
                                .a(
                                    .href(context.site.path(for: tag)),
                                    .text(tag.string)
                                )
                            )
                        }
                    )
                ),
                .footer(for: context.site)
            )
        )
    }
    
    func makeTagDetailsHTML(for page: TagDetailsPage,
                            context: PublishingContext<Site>) throws -> HTML? {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body(
                .header(for: context, selectedSection: nil),
                .wrapper(
                    .h1(
                        "Tagged with ",
                        .span(.class("tag"), .text(page.tag.string))
                    ),
                    .a(
                        .class("browse-all"),
                        .text("Browse all tags"),
                        .href(context.site.tagListPath)
                    ),
                    .itemList(
                        for: context.items(
                            taggedWith: page.tag,
                            sortedBy: \.date,
                            order: .descending
                        ),
                        on: context.site
                    )
                ),
                .footer(for: context.site)
            )
        )
    }
}


private extension Node where Context == HTML.BodyContext {
    static func wrapper(_ nodes: Node...) -> Node {
        .div(.class("wrapper"), .group(nodes))
    }
    
    static func header<T: Website>(
        for context: PublishingContext<T>,
        selectedSection: T.SectionID?
    ) -> Node {
        let sectionIDs = T.SectionID.allCases
        
        return .header(
            .wrapper(
                .a(.class("site-name"), .href("/"), .text(context.site.name)),
                .if(sectionIDs.count > 1,
                    .nav(
                        .ul(.forEach(sectionIDs) { section in
                            .li(.a(
                                .class(section == selectedSection ? "selected" : ""),
                                .href(context.sections[section].path),
                                .text(context.sections[section].title)
                                ))
                            })
                    )
                )
            )
        )
    }
    
    static func itemList<T: Website>(for items: [Item<T>], on site: T) -> Node {
        return .ul(
            .class("item-list"),
            .forEach(items) { item in
                .li(.article(
                    .h1(.a(
                        .href(item.path),
                        .text(item.title)
                        )),
                    .tagList(for: item, on: site),
                    .p(.text(item.description))
                    ))
            }
        )
    }
    
    static func sectionListWithAddedPages<T: Website>(for sections: SectionMap<T>, and pages: [Page]) -> Node {
        return .ul(
            .class("item-list"),
            .forEach(pages) { page in
                .li(.article(
                    .h1(.a(
                        .href(page.path),
                        .text(page.title)
                        ))
                    ))
            },
            .forEach(sections) { section in
                .li(.article(
                    .h1(.a(
                        .href(section.path),
                        .text(section.title)
                        ))
                    ))
            }
        )
    }
    
    static func tagList<T: Website>(for item: Item<T>, on site: T) -> Node {
        return .ul(.class("tag-list"), .forEach(item.tags) { tag in
            .li(.a(
                .href(site.path(for: tag)),
                .text(tag.string)
                ))
            })
    }
    
    static func footer<T: Website>(for site: T) -> Node {
        return .footer(
            .p(
                .text("Generated using "),
                .a(
                    .text("Publish"),
                    .href("https://github.com/johnsundell/publish")
                )
            ),
            .p(.a(
                .text("RSS feed"),
                .href("/feed.rss")
                ))
        )
    }
    
    /// Add an audio player and it's supporting elements for the Seara Publish Theme within the current context.
    /// - Parameter audio: The audio to add a player for.
    /// - Parameter showControls: Whether playback controls should be shown to the user.
    static func searaPlayer(for audio: Audio,
                            artworkSrc: Path, //eg. missing artwork image.
        showControls: Bool = true) -> Node {
        return .div(.class("player"),
                    .audio(
                        .controls(showControls),
                        .source(.type(audio.format), .src(audio.url))
            ),
                    .p("Artista: ", .span(.id("artist"))),
                    .p("Música: ", .span(.id("title"))),
                    .div(.img(.src(artworkSrc), .id("artwork"))),
                    .pre(.id("lyrics"))
        )
    }
}
