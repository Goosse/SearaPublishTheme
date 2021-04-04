/**
 *  Publish
 *  Copyright (c) John Sundell 2019
 *  MIT license, see LICENSE file for details
 */

import Plot
import Publish
import Files
import Foundation

extension Website {
    var resourceTag: Int { Int.random(in: 1..<1000000) }
}


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
            .head(for: index, on: context.site, titleSeparator: " | ", stylesheetPaths: ["/styles.css?\(context.site.resourceTag)"], rssFeedPath: .defaultForRSSFeed, rssFeedTitle: nil),
    //        .head(for: index, on: context.site),
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
                                                                  .p(.class("no-ar"),"NO AR")
                                                                //                                                            ,
                                                                //                                                                  .p(.class("programa-no-ar"),"Seara Esporte Clube")
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
            .head(for: section, on: context.site, titleSeparator: " | ", stylesheetPaths: ["/styles.css?\(context.site.resourceTag)"], rssFeedPath: .defaultForRSSFeed, rssFeedTitle: nil),
            .body(.class(section.id.rawValue),
                  .header(for: context, currentPagePath: nil),
                  .banner("orange", .bannerInfo(
                    .h1(.text(section.title)),
                    .p(.class("description"),
                       .text(section.description)
                    ),
                    .shareButton(for: section, on: context.site)
                    ),
                          .unwrap(section.imagePath){.div(.class("banner-artwork"),
                                                          .img(.src($0))
                            )}
                ),
                  .wrapper("episodios",
                           .h2(.text("Episódios")),
                           .itemList(for: section.items, on: context.site),
                           .button(.class("call-to-action"), .text("Inscreva-se no Podcast"), .attribute(named: "onclick", value: "removeClass('inscrever-dialog', 'hidden');disableScrolling();"))
                ),
                  .footer(for: context.site),
                  .compartilharDialog(section.title, imgUrl:section.imagePath, shareUrl: section.path, on:context.site),
                  .inscreverDialog(section.title, imgUrl: section.imagePath, on: context.site),
                  .episodePlayer(imgUrl:section.imagePath),
                  .script(.src("/playerScript.js?\(context.site.resourceTag)"))
            )
        )
    }
    
    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site, titleSeparator: " | ", stylesheetPaths: ["/styles.css?\(context.site.resourceTag)"], rssFeedPath: .defaultForRSSFeed, rssFeedTitle: nil),
            .body(.class("item-page \(item.sectionID.rawValue)"),
                  .header(for: context, currentPagePath: nil),
                  .banner("orange",
                          .bannerInfo(
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
                  .footer(for: context.site),
                  .compartilharDialog(item.title, imgUrl:context.sections[item.sectionID].imagePath, shareUrl: item.path, on:context.site),
                  .script(.src("/playerScript.js?\(context.site.resourceTag)"))
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
            .head(for: page, on: context.site, titleSeparator: " | ", stylesheetPaths: ["/styles.css?\(context.site.resourceTag)"], rssFeedPath: .defaultForRSSFeed, rssFeedTitle: nil),
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
            .head(for: page, on: context.site, titleSeparator: " | ", stylesheetPaths: ["/styles.css?\(context.site.resourceTag)"], rssFeedPath: .defaultForRSSFeed, rssFeedTitle: nil),
            .body(.class("live-player"),
                  .header(for: context, currentPagePath: page.path),
                  .wrapper("ao-vivo",
                           .wrapper("player",
                                    .wrapper("col-1",
                                             .img(.id("live-artwork"),
                                                  .src("/recursos/capas/ao-vivo.jpg")
                                        )
                            ),
                                    //                                    .wrapper("col-2",
                            //                                             .h1(.id("live-track-title"), "Song Title"),
                            //                                             .p(.id("live-track-artist"), "Artista"),
                            //                                             .div(.class("button-wrapper"),
                            //                                                  .shareButton(),
                            //                                                  .a(.class("comprar-link button"),.href("/"),
                            //                                                     .span(.class("icon")),  .span(.class("label"), "Comprar"))
                            //                                        )
                            //                            ),
                            //                                    .wrapper("col-3",
                            //                                             .h2(.class("track-info-title"), "Informações"),
                            //                                             .p(.id("track-info"), "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium dolorem que laudantium, totam rem aperia."),
                            //                                             .div(.class("button-wrapper"),
                            //                                                  .button(.class("curtir button"),
                            //                                                          .div(.class("icon")),
                            //                                                          .span(.class("label"), "Curtir")
                            //                                                ),
                            //                                                  .button(.class("ver-letra button"),
                            //                                                          .div(.class("icon")),
                            //                                                          .span(.class("label"), "Ver a letra")
                            //                                                )
                            //                                        )
                            //                            ),
                            .wrapper("col-4",
                                     .span(.class("divider")),
                                     .button(.class("play"), .id("live-play-button"), .attribute(named: "onclick", value: "toggleLiveStream(this);")),
                                     .div(.id("volume"), .class("slider-wrapper hidden"),
                                          .div(.id("volume-slider"), .class("slider"),
                                               .div(.id("volume-active-range"), .class("slider-active-range"),
                                                    .div(.id("volume-handle"), .class("slider-handle"))
                                            )
                                        ),
                                          .div(.class("icon"))
                                ),
                                     .unwrap(page.audio, {
                                        .audio(.id("player"),
                                               .controls(false),
                                               .source(.type($0.format), .src($0.url))
                                        )
                                     })
                                
                            )
                    )
                ),
                  .footer(for: context.site),
                  .script(.src("/playerScript.js?\(context.site.resourceTag)"))
            )
        )
    }
    
    func makeTagListHTML(for page: TagListPage,
                         context: PublishingContext<Site>) throws -> HTML? {
        
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site, titleSeparator: " | ", stylesheetPaths: ["/styles.css?\(context.site.resourceTag)"], rssFeedPath: .defaultForRSSFeed, rssFeedTitle: nil),
            .body(
                .header(for: context, currentPagePath: nil),
                .banner("orange", .bannerInfo(
                    .h1("Todas as Palavras Chaves")
                    )
                ),
                .wrapper("",
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
            .head(for: page, on: context.site, titleSeparator: " | ", stylesheetPaths: ["/styles.css?\(context.site.resourceTag)"], rssFeedPath: .defaultForRSSFeed, rssFeedTitle: nil),
            .body(
                .header(for: context, currentPagePath: nil),
                .banner("orange", .bannerInfo(
                    .h1("Palavra Chave: ", .span(.class("tag"),.text(page.tag.string))),
                    .shareButton(for: page, on: context.site)
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
                .footer(for: context.site),
                .compartilharDialog(page.title, imgUrl:nil, shareUrl: page.path, on:context.site),
                .script(.src("/playerScript.js?\(context.site.resourceTag)"))
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
    
    static func episodePlayer(imgUrl:Path?) -> Node {
        .div(.id("bar-player-wrapper"), .class("closed"),
             .attribute(named: "onclick", value: "expandPlayer();"),
             .attribute(named: "onmousedown", value: "function(e){e.stopPropagation();};"),
             .unwrap(imgUrl){ .img(.class("bar-player-artwork"), .src($0.absoluteString))},
             .wrapper("flex",
                      .div(.id("bar-player-title"), .text("Bernardo Boone Parte 2")),
                      .div(.id("scrubber"), .class("slider-wrapper horizontal"),
                           .div(.id("scrubber-slider"), .class("slider"),
                                .div(.id("scrubber-active-range"), .class("slider-active-range"),
                                     .div(.id("scrubber-handle"), .class("slider-handle"))
                            )
                        ),
                           .div(.class("scrub-time"),
                                .span(.id("current-time"), "00:00"),
                                .span(.id("total-time"), "30:00")
                        )
                )
            ),
             .button(.class("play"), .id("bar-play-button"), .attribute(named: "onclick", value: "toggleStream(this);")),
             .div(.id("volume"), .class("slider-wrapper horizontal hidden"),
                  .div(.class("icon")),
                  .div(.id("volume-slider"), .class("slider"),
                       .div(.id("volume-active-range"), .class("slider-active-range"),
                            .div(.id("volume-handle"), .class("slider-handle"))
                    )
                )
            ),
             .div(.class("close"), .attribute(named: "onclick", value: "closePlayer(this);")),
             .audio(.id("player"),
                    .controls(false),
                    .source(.type(.mp3), .src(""))
            )
        )
    }
    
    static func compartilharDialog<T: Website>(_ title: String, imgUrl:Path?, shareUrl: Path, on site: T) -> Node {
        .div(.id("share-dialog"), .class("share modal hidden"),
             .div(.class("share dialog"),
                  .div(.class("close"), .attribute(named: "onclick", value: "closeDialog(this);")),
                  .unwrap(imgUrl){.img(.class("album-artwork"),
                                       .src($0.absoluteString)
                    )},
                  .p(.text("Compartilhe "),
                     .span(.id("share-title"), .text(title))),
                  .ul(.class("share-icons"),
                      .li(
                        .a(
                            .id("fb-share"),
                            .facebookSVG(""),
                            .href("https://www.facebook.com/sharer/sharer.php?u=\(site.url.absoluteString)\(shareUrl.absoluteString)"),
                            .target(.blank)
                        )
                    ),
                      .li(
                        .a(
                            .id("wa-share"),
                            .whatsAppSVG(""),
                            .href("https://api.whatsapp.com/send?text=\(site.url.absoluteString)\(shareUrl.absoluteString)"),
                            .target(.blank)
                        )
                    ),
                      .li(
                        .a(
                            .id("twitter-share"),
                            .twitterSVG(""),
                            .href("https://twitter.com/intent/tweet?url=\(site.url.absoluteString)\(shareUrl.absoluteString)"),
                            .target(.blank)
                        )
                    )
                    ,
                      .li(
                        .a(
                            .id("email-share"),
                            .emailSVG(""),
                            .href("mailto:?subject=Veja%20o%20que%20eu%20descrobi!&body=\(site.url.absoluteString)\(shareUrl.absoluteString)")                        )
                    )
                )
            )
        )
    }
    
    static func inscreverDialog<T: Website>(_ title: String, imgUrl:Path?, on site: T) -> Node {
        .div(.id("inscrever-dialog"), .class("inscrever modal hidden"),
             .div(.class("inscrever dialog"),
                  .div(.class("close"), .attribute(named: "onclick", value: "closeDialog(this);")),
                  .unwrap(imgUrl){.img(.class("album-artwork"),
                                       .src($0.absoluteString)
                    )},
                  .p(.text("Inscreva-se para sempre ouvir o"),
                     .br(),
                     .text(title)
                ),
                  .ul(.class("inscrever-logos"),
                      .li(
                        .a(
                            .applePodcastsSVG(""),
                            .href("https://podcasts.apple.com"),
                            .target(.blank)
                        )
                    ),
                      .li(
                        .a(
                            .spotifySVG(""),
                            .href("https://open.spotify.com/genre/podcasts-page"),
                            .target(.blank)
                        )
                    ),
                      .li(
                        .a(
                            .googlePodcastsSVG(""),
                            .href("https://podcasts.google.com"),
                            .target(.blank)
                        )
                    )
                    ,
                      .li(
                        .a(
                            .tuneInSVG(""),
                            .href("https://tunein.com/podcasts/"),
                            .target(.blank)
                        )
                    )
                )
            )
        )
    }
    
    static func header<T: Website>(
        for context: PublishingContext<T>,
        currentPagePath: Path?
    ) -> Node {
        
        return .header(
            .div(.class("header-wrapper"),
                 .a(.class("marca"), .href("/"), .img(.src("/marca.jpg"))),
                 .if(currentPagePath != "",
                     .nav(
                        .ul(
                            .li(.a(
                                //  .class(currentPagePath == "" ? "selected" : ""),
                                .href("/"),
                                .text("Início")
                                ))
                            //                        ,
                            //                        .li(.a(
                            //                            .class(currentPagePath == "ao-vivo" ? "selected" : ""),
                            //                            .href("/ao-vivo"),
                            //                            .text("Ao Vivo")
                            //                            ))
                        )
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
        func durationInSeconds(duration:Audio.Duration) -> Int {
            return duration.hours*3600 + duration.minutes*60 + duration.seconds
        }
        
        return .ul(
            .class("item-list"),
            .forEach(items) { item in
                .unwrap(item.audio) { audio in
                    .li(.article(
                        .unwrap(audio.duration){ dur in
                            .button(.class("play"), .attribute(named: "onclick", value: "playEpisode('\(audio.url)', '\(item.title)', '\(durationInSeconds(duration: dur))')"))
                        },
                        .div(.class("info"),
                             .h3(.if(withLink,
                                     .a(
                                        .href(item.path),
                                        .text(item.title)
                                ),
                                     else: .text(item.title))
                            ),
                             .unwrap(audio.duration){ dur in
                                .p(.class("date-time"), .text("\(dateFormatter.string(from:item.date))\(formatDuration(duration: dur))" ))},
                             .p(.class("description"), .text(item.description)),
                             .tagList(for: item, on: site)
                        ),
                        .shareButton(for: item, on: site)
                        // .shareButton(item.path)
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
    
    static func shareButton<T: Website>(for location:Publish.Location, on site: T) -> Node {
        return .button(.class("compartilhar"),
                       .attribute(named: "onclick", value: "shareUrl('\(site.url)\(location.path.absoluteString)', '\(location.title)')"),
                       .div(.class("icon")),
                       .span(.class("label"), "Compartilhar")
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
    //    static func searaPlayer(for audio: Audio,
    //                            artworkSrc: Path, //eg. missing artwork image.
    //        showControls: Bool = true) -> Node {
    //        return .audio(
    //                        .controls(showControls),
    //                        .source(.type(audio.format), .src(audio.url))
    //            )
    //    }
}
