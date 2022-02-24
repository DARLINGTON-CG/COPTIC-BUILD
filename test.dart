// // To parse this JSON data, do
// //
// //     final postUploadModelClass = postUploadModelClassFromJson(jsonString);

// import 'dart:convert';

// List<PostUploadModelClass> postUploadModelClassFromJson(String str) =>
//     List<PostUploadModelClass>.from(
//         json.decode(str).map((x) => PostUploadModelClass.fromJson(x)));

// String postUploadModelClassToJson(List<PostUploadModelClass> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class PostUploadModelClass {
//   PostUploadModelClass({
//     this.id,
//     this.date,
//     this.dateGmt,
//     this.guid,
//     this.modified,
//     this.modifiedGmt,
//     this.slug,
//     this.status,
//     this.type,
//     this.link,
//     this.title,
//     this.content,
//     this.excerpt,
//     this.author,
//     this.featuredMedia,
//     this.commentStatus,
//     this.pingStatus,
//     this.sticky,
//     this.template,
//     this.format,
//     this.meta,
//     this.categories,
//     this.tags,
//     this.metadata,
//     this.jetpackFeaturedMediaUrl,
//     this.links,
//   });

//   int id;
//   DateTime date;
//   DateTime dateGmt;
//   Guid guid;
//   DateTime modified;
//   DateTime modifiedGmt;
//   String slug;
//   StatusEnum status;
//   Type type;
//   String link;
//   Guid title;
//   Content content;
//   Content excerpt;
//   int author;
//   int featuredMedia;
//   Status commentStatus;
//   Status pingStatus;
//   bool sticky;
//   String template;
//   Format format;
//   List<dynamic> meta;
//   List<int> categories;
//   List<int> tags;
//   Metadata metadata;
//   String jetpackFeaturedMediaUrl;
//   Links links;

//   factory PostUploadModelClass.fromJson(Map<String, dynamic> json) =>
//       PostUploadModelClass(
//         id: json["id"] == null ? null : json["id"],
//         date: json["date"] == null ? null : DateTime.parse(json["date"]),
//         dateGmt:
//             json["date_gmt"] == null ? null : DateTime.parse(json["date_gmt"]),
//         guid: json["guid"] == null ? null : Guid.fromJson(json["guid"]),
//         modified:
//             json["modified"] == null ? null : DateTime.parse(json["modified"]),
//         modifiedGmt: json["modified_gmt"] == null
//             ? null
//             : DateTime.parse(json["modified_gmt"]),
//         slug: json["slug"] == null ? null : json["slug"],
//         status: json["status"] == null
//             ? null
//             : statusEnumValues.map[json["status"]],
//         type: json["type"] == null ? null : typeValues.map[json["type"]],
//         link: json["link"] == null ? null : json["link"],
//         title: json["title"] == null ? null : Guid.fromJson(json["title"]),
//         content:
//             json["content"] == null ? null : Content.fromJson(json["content"]),
//         excerpt:
//             json["excerpt"] == null ? null : Content.fromJson(json["excerpt"]),
//         author: json["author"] == null ? null : json["author"],
//         featuredMedia:
//             json["featured_media"] == null ? null : json["featured_media"],
//         commentStatus: json["comment_status"] == null
//             ? null
//             : statusValues.map[json["comment_status"]],
//         pingStatus: json["ping_status"] == null
//             ? null
//             : statusValues.map[json["ping_status"]],
//         sticky: json["sticky"] == null ? null : json["sticky"],
//         template: json["template"] == null ? null : json["template"],
//         format:
//             json["format"] == null ? null : formatValues.map[json["format"]],
//         meta: json["meta"] == null
//             ? null
//             : List<dynamic>.from(json["meta"].map((x) => x)),
//         categories: json["categories"] == null
//             ? null
//             : List<int>.from(json["categories"].map((x) => x)),
//         tags: json["tags"] == null
//             ? null
//             : List<int>.from(json["tags"].map((x) => x)),
//         metadata: json["metadata"] == null
//             ? null
//             : Metadata.fromJson(json["metadata"]),
//         jetpackFeaturedMediaUrl: json["jetpack_featured_media_url"] == null
//             ? null
//             : json["jetpack_featured_media_url"],
//         links: json["_links"] == null ? null : Links.fromJson(json["_links"]),
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id == null ? null : id,
//         "date": date == null ? null : date.toIso8601String(),
//         "date_gmt": dateGmt == null ? null : dateGmt.toIso8601String(),
//         "guid": guid == null ? null : guid.toJson(),
//         "modified": modified == null ? null : modified.toIso8601String(),
//         "modified_gmt":
//             modifiedGmt == null ? null : modifiedGmt.toIso8601String(),
//         "slug": slug == null ? null : slug,
//         "status": status == null ? null : statusEnumValues.reverse[status],
//         "type": type == null ? null : typeValues.reverse[type],
//         "link": link == null ? null : link,
//         "title": title == null ? null : title.toJson(),
//         "content": content == null ? null : content.toJson(),
//         "excerpt": excerpt == null ? null : excerpt.toJson(),
//         "author": author == null ? null : author,
//         "featured_media": featuredMedia == null ? null : featuredMedia,
//         "comment_status":
//             commentStatus == null ? null : statusValues.reverse[commentStatus],
//         "ping_status":
//             pingStatus == null ? null : statusValues.reverse[pingStatus],
//         "sticky": sticky == null ? null : sticky,
//         "template": template == null ? null : template,
//         "format": format == null ? null : formatValues.reverse[format],
//         "meta": meta == null ? null : List<dynamic>.from(meta.map((x) => x)),
//         "categories": categories == null
//             ? null
//             : List<dynamic>.from(categories.map((x) => x)),
//         "tags": tags == null ? null : List<dynamic>.from(tags.map((x) => x)),
//         "metadata": metadata == null ? null : metadata.toJson(),
//         "jetpack_featured_media_url":
//             jetpackFeaturedMediaUrl == null ? null : jetpackFeaturedMediaUrl,
//         "_links": links == null ? null : links.toJson(),
//       };
// }

// enum Status { OPEN }

// final statusValues = EnumValues({"open": Status.OPEN});

// class Content {
//   Content({
//     this.rendered,
//     this.protected,
//   });

//   String rendered;
//   bool protected;

//   factory Content.fromJson(Map<String, dynamic> json) => Content(
//         rendered: json["rendered"] == null ? null : json["rendered"],
//         protected: json["protected"] == null ? null : json["protected"],
//       );

//   Map<String, dynamic> toJson() => {
//         "rendered": rendered == null ? null : rendered,
//         "protected": protected == null ? null : protected,
//       };
// }

// enum Format { STANDARD }

// final formatValues = EnumValues({"standard": Format.STANDARD});

// class Guid {
//   Guid({
//     this.rendered,
//   });

//   String rendered;

//   factory Guid.fromJson(Map<String, dynamic> json) => Guid(
//         rendered: json["rendered"] == null ? null : json["rendered"],
//       );

//   Map<String, dynamic> toJson() => {
//         "rendered": rendered == null ? null : rendered,
//       };
// }

// class Links {
//   Links({
//     this.self,
//     this.collection,
//     this.about,
//     this.author,
//     this.replies,
//     this.versionHistory,
//     this.wpAttachment,
//     this.wpTerm,
//     this.curies,
//     this.predecessorVersion,
//     this.wpFeaturedmedia,
//   });

//   List<About> self;
//   List<About> collection;
//   List<About> about;
//   List<Author> author;
//   List<Author> replies;
//   List<VersionHistory> versionHistory;
//   List<About> wpAttachment;
//   List<WpTerm> wpTerm;
//   List<Cury> curies;
//   List<PredecessorVersion> predecessorVersion;
//   List<Author> wpFeaturedmedia;

//   factory Links.fromJson(Map<String, dynamic> json) => Links(
//         self: json["self"] == null
//             ? null
//             : List<About>.from(json["self"].map((x) => About.fromJson(x))),
//         collection: json["collection"] == null
//             ? null
//             : List<About>.from(
//                 json["collection"].map((x) => About.fromJson(x))),
//         about: json["about"] == null
//             ? null
//             : List<About>.from(json["about"].map((x) => About.fromJson(x))),
//         author: json["author"] == null
//             ? null
//             : List<Author>.from(json["author"].map((x) => Author.fromJson(x))),
//         replies: json["replies"] == null
//             ? null
//             : List<Author>.from(json["replies"].map((x) => Author.fromJson(x))),
//         versionHistory: json["version-history"] == null
//             ? null
//             : List<VersionHistory>.from(
//                 json["version-history"].map((x) => VersionHistory.fromJson(x))),
//         wpAttachment: json["wp:attachment"] == null
//             ? null
//             : List<About>.from(
//                 json["wp:attachment"].map((x) => About.fromJson(x))),
//         wpTerm: json["wp:term"] == null
//             ? null
//             : List<WpTerm>.from(json["wp:term"].map((x) => WpTerm.fromJson(x))),
//         curies: json["curies"] == null
//             ? null
//             : List<Cury>.from(json["curies"].map((x) => Cury.fromJson(x))),
//         predecessorVersion: json["predecessor-version"] == null
//             ? null
//             : List<PredecessorVersion>.from(json["predecessor-version"]
//                 .map((x) => PredecessorVersion.fromJson(x))),
//         wpFeaturedmedia: json["wp:featuredmedia"] == null
//             ? null
//             : List<Author>.from(
//                 json["wp:featuredmedia"].map((x) => Author.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "self": self == null
//             ? null
//             : List<dynamic>.from(self.map((x) => x.toJson())),
//         "collection": collection == null
//             ? null
//             : List<dynamic>.from(collection.map((x) => x.toJson())),
//         "about": about == null
//             ? null
//             : List<dynamic>.from(about.map((x) => x.toJson())),
//         "author": author == null
//             ? null
//             : List<dynamic>.from(author.map((x) => x.toJson())),
//         "replies": replies == null
//             ? null
//             : List<dynamic>.from(replies.map((x) => x.toJson())),
//         "version-history": versionHistory == null
//             ? null
//             : List<dynamic>.from(versionHistory.map((x) => x.toJson())),
//         "wp:attachment": wpAttachment == null
//             ? null
//             : List<dynamic>.from(wpAttachment.map((x) => x.toJson())),
//         "wp:term": wpTerm == null
//             ? null
//             : List<dynamic>.from(wpTerm.map((x) => x.toJson())),
//         "curies": curies == null
//             ? null
//             : List<dynamic>.from(curies.map((x) => x.toJson())),
//         "predecessor-version": predecessorVersion == null
//             ? null
//             : List<dynamic>.from(predecessorVersion.map((x) => x.toJson())),
//         "wp:featuredmedia": wpFeaturedmedia == null
//             ? null
//             : List<dynamic>.from(wpFeaturedmedia.map((x) => x.toJson())),
//       };
// }

// class About {
//   About({
//     this.href,
//   });

//   String href;

//   factory About.fromJson(Map<String, dynamic> json) => About(
//         href: json["href"] == null ? null : json["href"],
//       );

//   Map<String, dynamic> toJson() => {
//         "href": href == null ? null : href,
//       };
// }

// class Author {
//   Author({
//     this.embeddable,
//     this.href,
//   });

//   bool embeddable;
//   String href;

//   factory Author.fromJson(Map<String, dynamic> json) => Author(
//         embeddable: json["embeddable"] == null ? null : json["embeddable"],
//         href: json["href"] == null ? null : json["href"],
//       );

//   Map<String, dynamic> toJson() => {
//         "embeddable": embeddable == null ? null : embeddable,
//         "href": href == null ? null : href,
//       };
// }

// class Cury {
//   Cury({
//     this.name,
//     this.href,
//     this.templated,
//   });

//   Name name;
//   Href href;
//   bool templated;

//   factory Cury.fromJson(Map<String, dynamic> json) => Cury(
//         name: json["name"] == null ? null : nameValues.map[json["name"]],
//         href: json["href"] == null ? null : hrefValues.map[json["href"]],
//         templated: json["templated"] == null ? null : json["templated"],
//       );

//   Map<String, dynamic> toJson() => {
//         "name": name == null ? null : nameValues.reverse[name],
//         "href": href == null ? null : hrefValues.reverse[href],
//         "templated": templated == null ? null : templated,
//       };
// }

// enum Href { HTTPS_API_W_ORG_REL }

// final hrefValues =
//     EnumValues({"https://api.w.org/{rel}": Href.HTTPS_API_W_ORG_REL});

// enum Name { WP }

// final nameValues = EnumValues({"wp": Name.WP});

// class PredecessorVersion {
//   PredecessorVersion({
//     this.id,
//     this.href,
//   });

//   int id;
//   String href;

//   factory PredecessorVersion.fromJson(Map<String, dynamic> json) =>
//       PredecessorVersion(
//         id: json["id"] == null ? null : json["id"],
//         href: json["href"] == null ? null : json["href"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id == null ? null : id,
//         "href": href == null ? null : href,
//       };
// }

// class VersionHistory {
//   VersionHistory({
//     this.count,
//     this.href,
//   });

//   int count;
//   String href;

//   factory VersionHistory.fromJson(Map<String, dynamic> json) => VersionHistory(
//         count: json["count"] == null ? null : json["count"],
//         href: json["href"] == null ? null : json["href"],
//       );

//   Map<String, dynamic> toJson() => {
//         "count": count == null ? null : count,
//         "href": href == null ? null : href,
//       };
// }

// class WpTerm {
//   WpTerm({
//     this.taxonomy,
//     this.embeddable,
//     this.href,
//   });

//   Taxonomy taxonomy;
//   bool embeddable;
//   String href;

//   factory WpTerm.fromJson(Map<String, dynamic> json) => WpTerm(
//         taxonomy: json["taxonomy"] == null
//             ? null
//             : taxonomyValues.map[json["taxonomy"]],
//         embeddable: json["embeddable"] == null ? null : json["embeddable"],
//         href: json["href"] == null ? null : json["href"],
//       );

//   Map<String, dynamic> toJson() => {
//         "taxonomy": taxonomy == null ? null : taxonomyValues.reverse[taxonomy],
//         "embeddable": embeddable == null ? null : embeddable,
//         "href": href == null ? null : href,
//       };
// }

// enum Taxonomy { CATEGORY, POST_TAG }

// final taxonomyValues =
//     EnumValues({"category": Taxonomy.CATEGORY, "post_tag": Taxonomy.POST_TAG});

// class Metadata {
//   Metadata({
//     this.featuredAds,
//     this.regularAds,
//     this.wooId,
//     this.planTime,
//     this.planText,
//     this.planPrice,
//     this.popularPlan,
//     this.postPrice,
//     this.postPhone,
//     this.postWhatsapp,
//     this.postEmail,
//     this.postLocation,
//     this.postState,
//     this.postCity,
//     this.postLatitude,
//     this.postLongitude,
//     this.postAddress,
//     this.itemCondition,
//     this.classieraPostType,
//     this.classieraAllowBids,
//     this.postPerentCat,
//     this.customField,
//     this.wpbPostViewsCount,
//     this.postChildCat,
//     this.postInnerCat,
//     this.postCurrencyTag,
//     this.editLast,
//     this.editLock,
//     this.thumbnailId,
//     this.apssContentFlag,
//     this.featuredPost,
//     this.postOldPrice,
//     this.postVideo,
//     this.postWebUrl,
//     this.postWebUrlTxt,
//     this.wpPageTemplate,
//   });

//   List<dynamic> featuredAds;
//   List<String> regularAds;
//   List<dynamic> wooId;
//   List<dynamic> planTime;
//   List<dynamic> planText;
//   List<dynamic> planPrice;
//   List<String> popularPlan;
//   List<String> postPrice;
//   List<String> postPhone;
//   List<String> postWhatsapp;
//   List<PostEmail> postEmail;
//   List<PostLocation> postLocation;
//   List<String> postState;
//   List<String> postCity;
//   List<String> postLatitude;
//   List<String> postLongitude;
//   List<String> postAddress;
//   List<ItemCondition> itemCondition;
//   List<ClassieraPostType> classieraPostType;
//   List<ClassieraAllowBid> classieraAllowBids;
//   List<String> postPerentCat;
//   List<String> customField;
//   List<String> wpbPostViewsCount;
//   List<String> postChildCat;
//   List<String> postInnerCat;
//   List<String> postCurrencyTag;
//   List<String> editLast;
//   List<String> editLock;
//   List<String> thumbnailId;
//   List<String> apssContentFlag;
//   List<String> featuredPost;
//   List<String> postOldPrice;
//   List<String> postVideo;
//   List<String> postWebUrl;
//   List<String> postWebUrlTxt;
//   List<String> wpPageTemplate;

//   factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
//         featuredAds: json["featured_ads"] == null
//             ? null
//             : List<dynamic>.from(json["featured_ads"].map((x) => x)),
//         regularAds: json["regular_ads"] == null
//             ? null
//             : List<String>.from(
//                 json["regular_ads"].map((x) => x == null ? null : x)),
//         wooId: json["woo_id"] == null
//             ? null
//             : List<dynamic>.from(json["woo_id"].map((x) => x)),
//         planTime: json["plan_time"] == null
//             ? null
//             : List<dynamic>.from(json["plan_time"].map((x) => x)),
//         planText: json["plan_text"] == null
//             ? null
//             : List<dynamic>.from(json["plan_text"].map((x) => x)),
//         planPrice: json["plan_price"] == null
//             ? null
//             : List<dynamic>.from(json["plan_price"].map((x) => x)),
//         popularPlan: json["popular_plan"] == null
//             ? null
//             : List<String>.from(json["popular_plan"].map((x) => x)),
//         postPrice: json["post_price"] == null
//             ? null
//             : List<String>.from(json["post_price"].map((x) => x)),
//         postPhone: json["post_phone"] == null
//             ? null
//             : List<String>.from(json["post_phone"].map((x) => x)),
//         postWhatsapp: json["post_whatsapp"] == null
//             ? null
//             : List<String>.from(json["post_whatsapp"].map((x) => x)),
//         postEmail: json["post_email"] == null
//             ? null
//             : List<PostEmail>.from(
//                 json["post_email"].map((x) => postEmailValues.map[x])),
//         postLocation: json["post_location"] == null
//             ? null
//             : List<PostLocation>.from(
//                 json["post_location"].map((x) => postLocationValues.map[x])),
//         postState: json["post_state"] == null
//             ? null
//             : List<String>.from(json["post_state"].map((x) => x)),
//         postCity: json["post_city"] == null
//             ? null
//             : List<String>.from(json["post_city"].map((x) => x)),
//         postLatitude: json["post_latitude"] == null
//             ? null
//             : List<String>.from(json["post_latitude"].map((x) => x)),
//         postLongitude: json["post_longitude"] == null
//             ? null
//             : List<String>.from(json["post_longitude"].map((x) => x)),
//         postAddress: json["post_address"] == null
//             ? null
//             : List<String>.from(json["post_address"].map((x) => x)),
//         itemCondition: json["item-condition"] == null
//             ? null
//             : List<ItemCondition>.from(
//                 json["item-condition"].map((x) => itemConditionValues.map[x])),
//         classieraPostType: json["classiera_post_type"] == null
//             ? null
//             : List<ClassieraPostType>.from(json["classiera_post_type"]
//                 .map((x) => classieraPostTypeValues.map[x])),
//         classieraAllowBids: json["classiera_allow_bids"] == null
//             ? null
//             : List<ClassieraAllowBid>.from(json["classiera_allow_bids"]
//                 .map((x) => classieraAllowBidValues.map[x])),
//         postPerentCat: json["post_perent_cat"] == null
//             ? null
//             : List<String>.from(json["post_perent_cat"].map((x) => x)),
//         customField: json["custom_field"] == null
//             ? null
//             : List<String>.from(
//                 json["custom_field"].map((x) => x == null ? null : x)),
//         wpbPostViewsCount: json["wpb_post_views_count"] == null
//             ? null
//             : List<String>.from(json["wpb_post_views_count"].map((x) => x)),
//         postChildCat: json["post_child_cat"] == null
//             ? null
//             : List<String>.from(json["post_child_cat"].map((x) => x)),
//         postInnerCat: json["post_inner_cat"] == null
//             ? null
//             : List<String>.from(json["post_inner_cat"].map((x) => x)),
//         postCurrencyTag: json["post_currency_tag"] == null
//             ? null
//             : List<String>.from(
//                 json["post_currency_tag"].map((x) => x == null ? null : x)),
//         editLast: json["_edit_last"] == null
//             ? null
//             : List<String>.from(json["_edit_last"].map((x) => x)),
//         editLock: json["_edit_lock"] == null
//             ? null
//             : List<String>.from(json["_edit_lock"].map((x) => x)),
//         thumbnailId: json["_thumbnail_id"] == null
//             ? null
//             : List<String>.from(json["_thumbnail_id"].map((x) => x)),
//         apssContentFlag: json["apss_content_flag"] == null
//             ? null
//             : List<String>.from(json["apss_content_flag"].map((x) => x)),
//         featuredPost: json["featured_post"] == null
//             ? null
//             : List<String>.from(json["featured_post"].map((x) => x)),
//         postOldPrice: json["post_old_price"] == null
//             ? null
//             : List<String>.from(json["post_old_price"].map((x) => x)),
//         postVideo: json["post_video"] == null
//             ? null
//             : List<String>.from(json["post_video"].map((x) => x)),
//         postWebUrl: json["post_web_url"] == null
//             ? null
//             : List<String>.from(json["post_web_url"].map((x) => x)),
//         postWebUrlTxt: json["post_web_url_txt"] == null
//             ? null
//             : List<String>.from(json["post_web_url_txt"].map((x) => x)),
//         wpPageTemplate: json["_wp_page_template"] == null
//             ? null
//             : List<String>.from(json["_wp_page_template"].map((x) => x)),
//       );

//   Map<String, dynamic> toJson() => {
//         "featured_ads": featuredAds == null
//             ? null
//             : List<dynamic>.from(featuredAds.map((x) => x)),
//         "regular_ads": regularAds == null
//             ? null
//             : List<dynamic>.from(regularAds.map((x) => x == null ? null : x)),
//         "woo_id":
//             wooId == null ? null : List<dynamic>.from(wooId.map((x) => x)),
//         "plan_time": planTime == null
//             ? null
//             : List<dynamic>.from(planTime.map((x) => x)),
//         "plan_text": planText == null
//             ? null
//             : List<dynamic>.from(planText.map((x) => x)),
//         "plan_price": planPrice == null
//             ? null
//             : List<dynamic>.from(planPrice.map((x) => x)),
//         "popular_plan": popularPlan == null
//             ? null
//             : List<dynamic>.from(popularPlan.map((x) => x)),
//         "post_price": postPrice == null
//             ? null
//             : List<dynamic>.from(postPrice.map((x) => x)),
//         "post_phone": postPhone == null
//             ? null
//             : List<dynamic>.from(postPhone.map((x) => x)),
//         "post_whatsapp": postWhatsapp == null
//             ? null
//             : List<dynamic>.from(postWhatsapp.map((x) => x)),
//         "post_email": postEmail == null
//             ? null
//             : List<dynamic>.from(
//                 postEmail.map((x) => postEmailValues.reverse[x])),
//         "post_location": postLocation == null
//             ? null
//             : List<dynamic>.from(
//                 postLocation.map((x) => postLocationValues.reverse[x])),
//         "post_state": postState == null
//             ? null
//             : List<dynamic>.from(postState.map((x) => x)),
//         "post_city": postCity == null
//             ? null
//             : List<dynamic>.from(postCity.map((x) => x)),
//         "post_latitude": postLatitude == null
//             ? null
//             : List<dynamic>.from(postLatitude.map((x) => x)),
//         "post_longitude": postLongitude == null
//             ? null
//             : List<dynamic>.from(postLongitude.map((x) => x)),
//         "post_address": postAddress == null
//             ? null
//             : List<dynamic>.from(postAddress.map((x) => x)),
//         "item-condition": itemCondition == null
//             ? null
//             : List<dynamic>.from(
//                 itemCondition.map((x) => itemConditionValues.reverse[x])),
//         "classiera_post_type": classieraPostType == null
//             ? null
//             : List<dynamic>.from(classieraPostType
//                 .map((x) => classieraPostTypeValues.reverse[x])),
//         "classiera_allow_bids": classieraAllowBids == null
//             ? null
//             : List<dynamic>.from(classieraAllowBids
//                 .map((x) => classieraAllowBidValues.reverse[x])),
//         "post_perent_cat": postPerentCat == null
//             ? null
//             : List<dynamic>.from(postPerentCat.map((x) => x)),
//         "custom_field": customField == null
//             ? null
//             : List<dynamic>.from(customField.map((x) => x == null ? null : x)),
//         "wpb_post_views_count": wpbPostViewsCount == null
//             ? null
//             : List<dynamic>.from(wpbPostViewsCount.map((x) => x)),
//         "post_child_cat": postChildCat == null
//             ? null
//             : List<dynamic>.from(postChildCat.map((x) => x)),
//         "post_inner_cat": postInnerCat == null
//             ? null
//             : List<dynamic>.from(postInnerCat.map((x) => x)),
//         "post_currency_tag": postCurrencyTag == null
//             ? null
//             : List<dynamic>.from(
//                 postCurrencyTag.map((x) => x == null ? null : x)),
//         "_edit_last": editLast == null
//             ? null
//             : List<dynamic>.from(editLast.map((x) => x)),
//         "_edit_lock": editLock == null
//             ? null
//             : List<dynamic>.from(editLock.map((x) => x)),
//         "_thumbnail_id": thumbnailId == null
//             ? null
//             : List<dynamic>.from(thumbnailId.map((x) => x)),
//         "apss_content_flag": apssContentFlag == null
//             ? null
//             : List<dynamic>.from(apssContentFlag.map((x) => x)),
//         "featured_post": featuredPost == null
//             ? null
//             : List<dynamic>.from(featuredPost.map((x) => x)),
//         "post_old_price": postOldPrice == null
//             ? null
//             : List<dynamic>.from(postOldPrice.map((x) => x)),
//         "post_video": postVideo == null
//             ? null
//             : List<dynamic>.from(postVideo.map((x) => x)),
//         "post_web_url": postWebUrl == null
//             ? null
//             : List<dynamic>.from(postWebUrl.map((x) => x)),
//         "post_web_url_txt": postWebUrlTxt == null
//             ? null
//             : List<dynamic>.from(postWebUrlTxt.map((x) => x)),
//         "_wp_page_template": wpPageTemplate == null
//             ? null
//             : List<dynamic>.from(wpPageTemplate.map((x) => x)),
//       };
// }

// enum ClassieraAllowBid { ALLOW, DISALLOW }

// final classieraAllowBidValues = EnumValues(
//     {"allow": ClassieraAllowBid.ALLOW, "disallow": ClassieraAllowBid.DISALLOW});

// enum ClassieraPostType { CLASSIERA_REGULAR }

// final classieraPostTypeValues =
//     EnumValues({"classiera_regular": ClassieraPostType.CLASSIERA_REGULAR});

// enum ItemCondition { NEW, USED }

// final itemConditionValues =
//     EnumValues({"new": ItemCondition.NEW, "used": ItemCondition.USED});

// enum PostEmail {
//   ABCDED_GMAIL_COM,
//   EMPTY,
//   THE_9153553_QQ_COM,
//   IMTIAZJAN10_GMAIL_COM,
//   TALHAJAVED490_GMAIL_COM
// }

// final postEmailValues = EnumValues({
//   "abcded@gmail.com": PostEmail.ABCDED_GMAIL_COM,
//   "": PostEmail.EMPTY,
//   "imtiazjan10@gmail.com": PostEmail.IMTIAZJAN10_GMAIL_COM,
//   "talhajaved490@gmail.com": PostEmail.TALHAJAVED490_GMAIL_COM,
//   "9153553@qq.com": PostEmail.THE_9153553_QQ_COM
// });

// enum PostLocation { QATAR, EMPTY, UNITED_KINGDOM }

// final postLocationValues = EnumValues({
//   "": PostLocation.EMPTY,
//   "Qatar": PostLocation.QATAR,
//   "United Kingdom": PostLocation.UNITED_KINGDOM
// });

// enum StatusEnum { PUBLISH }

// final statusEnumValues = EnumValues({"publish": StatusEnum.PUBLISH});

// enum Type { POST }

// final typeValues = EnumValues({"post": Type.POST});

// class EnumValues<T> {
//   Map<String, T> map;
//   Map<T, String> reverseMap;

//   EnumValues(this.map);

//   Map<T, String> get reverse {
//     if (reverseMap == null) {
//       reverseMap = map.map((k, v) => new MapEntry(v, k));
//     }
//     return reverseMap;
//   }
// }