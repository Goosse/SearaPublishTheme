/**
 *  Publish
 *  Copyright (c) John Sundell 2019
 *  MIT license, see LICENSE file for details
 */

import Plot
import Publish
import Files
import Foundation

public extension Theme {
    
    ///  Custom theme for radioseara.fm
    static var seara: Self {
        Theme(
            htmlFactory: SearaHTMLFactory(),
            resourcePaths: ["Resources/SearaTheme/styles.css",
                            "Resources/SearaTheme/playerScript.js",
                            "Resources/SearaTheme/theme-resources/marca.jpg",
                            "Resources/SearaTheme/theme-resources/banner-marca-color-75.png",
                            "Resources/SearaTheme/theme-resources/facebook.png",
                            "Resources/SearaTheme/theme-resources/instagram.png",
                            "Resources/SearaTheme/theme-resources/whatsapp.png",
                            "Resources/SearaTheme/theme-resources/youtube.png",
                            "Resources/SearaTheme/xilosa.ttf"
            ]
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
                .header(for: context, currentPagePath: index.path),
                .banner("green",  .bannerInfo(
                                        .h1(.text(index.title)),
                                        .p(.class("description"),
                                            .text(context.site.description)
                    )
                    ),
                        .unwrap(context.site.imagePath) { .div(.class("banner-artwork"),
                                 .a(.href("/ao-vivo"),
                                    .img(.src($0)),
                                    .p(.class("ouca-agora"),"Ouça Agora"),
                                    .p(.class("no-ar"),"NO AR"),
                                    .p(.class("programa-no-ar"),"Seara Esporte Clube")
                                )
                        )}
                ),
                .wrapper("home",
                    .h2("Programas"),
                    .sectionList(for: context.sections)
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
            .body(.class(section.id.rawValue),
                .header(for: context, currentPagePath: nil),
                .banner("orange", .bannerInfo(
                        .h1(.text(section.title)),
                        .p(.class("description"),
                           .text(section.description)
                    ),
                        .shareButton()
                        ),
                .unwrap(section.imagePath){.div(.class("banner-artwork"),
                    .img(.src($0))
                    )}
                    ),
                .wrapper("episodios",
                    .h2(.text("Episódios")),
                    .itemList(for: section.items, on: context.site),
                    .button(.class("call-to-action"), .text("Inscreva-se no Podcast"))
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
            .body(.class("item-page \(item.sectionID.rawValue)"),
                  .header(for: context, currentPagePath: nil),
                  .banner("orange", .bannerInfo(
                    .h1(.text(item.title)),
                    .h2("de \(context.sections[item.sectionID].title)"),
                    .p(.class("description"),
                       .text(context.sections[item.sectionID].description)
                    )
                    ),
                          .unwrap(context.sections[item.sectionID].imagePath){.div(.class("banner-artwork"),
                                                                                   .img(.src($0))
                            )}
                ),
                  .wrapper("episodios",
                           .itemList(for: [item], on: context.site, withLink: false),
                           .a(.class("call-to-action"), .href(context.sections[item.sectionID].path), .text("Veja Todos"))
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
                .header(for: context, currentPagePath: page.path),
                .wrapper("",.contentBody(page.body)),
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
                .header(for: context, currentPagePath: page.path),
                .wrapper("", .unwrap(page.audio, { .searaPlayer(for: $0, artworkSrc: Path("/recursos/missingArtwork.jpg")) }),
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
                .header(for: context, currentPagePath: nil),
                .wrapper("",
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
                .header(for: context, currentPagePath: nil),
                .banner("orange", .bannerInfo(
                    .h1("Palavra Chave: ", .span(.class("tag"),.text(page.tag.string))),
                    .shareButton()
                    )
                ),
                .wrapper("episodios",
                         .itemList(
                            for: context.items(
                                taggedWith: page.tag,
                                sortedBy: \.date,
                            order: .descending
                        ),
                        on: context.site
                    ),
                    .a(
                        .class("call-to-action"),
                        .text("Veja Todas as Palavras Chaves"),
                        .href(context.site.tagListPath)
                    )
                ),
                .footer(for: context.site)
            )
        )
    }
}


private extension Node where Context == HTML.BodyContext {
    static func wrapper(_ extraClasses: String, _ nodes: Node...) -> Node {
        .div(.class("wrapper \(extraClasses)"), .group(nodes))
    }
    
    static func banner(_ colorClass: String,_ nodes: Node...) -> Node {
        .div(.class("banner \(colorClass)"), .group(nodes))
    }

    static func bannerInfo(_ nodes: Node...) -> Node {
        .div(.class("info"), .group(nodes))
    }
    
    static func header<T: Website>(
        for context: PublishingContext<T>,
        currentPagePath: Path?
    ) -> Node {
        
        return .header(
            .div(.class("header-wrapper"),
                .a(.class("marca"), .href("/"), .img(.src("/marca.jpg"))),
                .nav(
                    .ul(
                        .li(.a(
                            .class(currentPagePath == "" ? "selected" : ""),
                            .href("/"),
                            .text("Programas")
                            )),
                        .li(.a(
                            .class(currentPagePath == "ao-vivo" ? "selected" : ""),
                            .href("/ao-vivo"),
                            .text("Ao Vivo")
                            ))
                    )
                )
            )
        )
    }
    
    static func itemList<T: Website>(for items: [Item<T>], on site: T) -> Node {
        return .itemList(for: items, on: site, withLink: true)
    }
    
    static func itemList<T: Website>(for items: [Item<T>], on site: T, withLink:Bool) -> Node {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d' de 'MMM, yyyy"
        
        func formatDuration(duration:Audio.Duration) -> String{
            
            
            let totalMinutes = duration.hours*60 + duration.minutes + (duration.seconds>0 ? Int(1) : Int(0))
            return " | \(totalMinutes) min"
        }
        
        return .ul(
            .class("item-list"),
            .forEach(items) { item in
                .unwrap(item.audio) {
                    .li(.article(
                        .button(.class("play")),
                        .div(.class("info"),
                             .h3(.if(withLink,
                                .a(
                                .href(item.path),
                                .text(item.title)
                                ),
                                else: .text(item.title))
                            ),
                             .unwrap($0.duration){
                                .p(.class("date-time"), .text("\(dateFormatter.string(from:item.date))\(formatDuration(duration: $0))" ))},
                             .p(.class("description"), .text(item.description)),
                             .tagList(for: item, on: site)
                        ),
                        .shareButton()
                        )
                    )
                }
                
            }
        )
    }
    
    static func sectionList<T: Website>(for sections: SectionMap<T>) -> Node {
        return .ul(
            .class("program-list"),
            .forEach(sections) { section in
                .li(
                    .a(.href(section.path),
                       .unwrap(section.imagePath){
                        .div(.class("artwork-wrapper"),
                             .img(.src($0)),
                             .div(.class("tint"),
                                     .div(.class("play overlay"))
                            )
                        )},
                       .h3(
                        .text(section.title)
                        ),
                       .p(
                        .text("Sinopse lorem ipsum dolor site amet"))
                    )
                )
            }
        )
    }
    
    static func tagList<T: Website>(for item: Item<T>, on site: T) -> Node {
        return .ul(.class("tag-list"), .forEach(item.tags) { tag in
            .li(.a(.class("tag"),
                .href(site.path(for: tag)),
                .text(tag.string)
                ))
            })
    }
    
    static func shareButton() -> Node {
        return .button(.class("compartilhar"),
                       .div(.class("icon")),
                       .text("Compartilhar")
        )
    }
    
    static func footer<T: Website>(for site: T) -> Node {
        return .footer(
            .div(.class("footer-wrapper"),
                 .div(.class("social-wrapper"),
                      .p(.class("participe-social"),
                        .text("Participe de Nossas Redes Sociais")
                        ),
                      .ul(.class("social-buttons-list"),
                          .li(.a(
                            .href(Path("https://fb.me/RadioSeara102.7")),
                            .target(.blank),
                            .rel(.noopener),
                            .rel(.noreferrer),
                                  .img(.src("/facebook.png"))
                            )
                        ),
                          .li(.a(
                              .href(Path("https://www.youtube.com/channel/UCiMyTT5oSoh69sDJNsOpDlg")),
                              .target(.blank),
                              .rel(.noopener),
                              .rel(.noreferrer),
                                    .img(.src("/youtube.png"))
                              )
                          ),
                          .li(.a(
                              .href(Path("https://www.instagram.com/radioseara/")),
                              .target(.blank),
                              .rel(.noopener),
                              .rel(.noreferrer),
                                    .img(.src("/instagram.png"))
                              )
                          ),
                          .li(.a(
                              .href(Path("https://wa.me/558836721221")),
                              .target(.blank),
                              .rel(.noopener),
                              .rel(.noreferrer),
                                    .img(.src("/whatsapp.png"))
                              )
                          )
                    )
                ),
                 .div(.class("copyright-wrapper"),
                      .p(.class("copyright"),
                         .text("&copy;\(Calendar.current.component(.year, from: Date())) Rádio Seara - Todos os direitos reservados."))
                )
            )
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
