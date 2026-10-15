enum RecordType {
  profile,
  post,
  hashtag,
  location,
}

enum UserRole {
  admin,
  user,
}

enum SearchFrom {
  username,
  email,
  phone,
}

enum TimelineType { posts, mentions, videos, saved }

enum PostCategory {
  basic,
  competition,
  club,
  reel,
  reshare,
  event,
  fundRaising
}

enum PostOptionType { camera, gallery, video, drawing, audio, gif, poll }

enum PostContentType {
  text,
  media,
  location,
  poll,
  event,
  competitionAdded,
  competitionResultDeclared,
  job,
  fundRaising,
  offer,
  classified,
  club,
  donation,
  openGroup
}

enum PostMediaType { all, photo, video, audio }

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
}

enum MessageContentType {
  text,
  photo,
  video,
  audio,
  gif,
  sticker,
  contact,
  file,
  location,
  reply,
  forward,
  post,
  story,
  drawing,
  profile,
  group,
  groupAction,
  gift,
  textReplyOnStory,
  reactedOnStory,
}

enum UploadMediaType {
  shop,
  storyOrHighlights,
  chat,
  club,
  verification,
  uploadResume,
  event,
  post
}

///Media picker selection type
enum GalleryMediaType {
  ///make picker to select only image file
  photo,
  gif,

  ///make picker to select only video file
  video,

  ///make picker to select only audio file
  audio,

  ///make picker to select only pdf file
  pdf,

  ///make picker to select only ppt file
  ppt,

  ///make picker to select only doc file
  doc,

  ///make picker to select only xls file
  xls,

  ///make picker to select only txt file
  txt,

  ///make picker to select any media file
  all,
}

enum ChatMessageActionMode { none, reply, forward, star, delete, edit }

enum AgoraCallType {
  audio,
  video,
}

enum PaymentGateway {
  creditCard,
  // applePay,
  // paypal,
  razorpay,
  wallet,
  stripe,
  // googlePay,
  inAppPurchase,
  // flutterWave
}

enum BookingStatus { confirmed, cancelled }

enum TvBannerType { tv, show }

enum PodcastBannerType { host, show }

enum RelationsRevealSetting { none, followers, all }

enum GenderType { male, female, other }

enum SMNotificationType {
  like,
  comment,
  follow,
  followRequest,
  gift,
  clubInvitation,
  competitionAdded,
  relationInvite,
  none,
  verification,
  supportRequest,
  subscribed,
  collaborate
}

enum CommentType { text, image, video, gif }

enum LiveBattleResultType { winner, draw }

enum BattleStatus { none, accepted, started, completed }

enum OfferSource { normal, fav }

enum GoalType { profile, website, message }

enum ItemViewSource { normal, promotion }

enum UserViewSourceType { post, reel, story }

enum TransactionType {
  credit,
  debit,
}

enum TransactionMedium {
  coin,
  money,
}

enum PaymentType {
  package,
  award,
  withdrawal,
  withdrawalRefund,
  liveTvSubscribe,
  giftSent,
  giftReceived,
  redeemCoin,
  eventTicket,
  eventTicketRefund,
  datingSubscription,
  promotion,
  promotionRefund,
  fundRaising,
  featureAd,
  bannerAd,
  subscription
}

enum PaymentMode {
  inAppPurchase,
  paypal,
  wallet,
  stripe,
  razorpay,
  flutterWave
}

enum DatingActions {
  liked,
  rejected,
  undoLiked,
}

enum FollowingStatus {
  notFollowing,
  requested,
  following,
}

enum PlayStateState { paused, playing, loading, idle }

enum LiveUserRole { host, moderator, viewer }

enum LiveStreamingStatus {
  none,
  checking,
  preparing,
  streaming,
  ended,
  failed
}

enum SMSGateway { twilio, sms91, firebase }

enum SubscribedStatus { notSubscribed, subscribed, expired }

enum ProcessingPaymentStatus { inProcess, completed, failed }

enum PinContentType { post, comment }

enum CollaborationStatusType {
  deleted,
  pending,
  rejected,
  cancelled,
  accepted
}

enum EventStatus {
  upcoming,
  cancelled,
  active,
  completed
}

enum ReactionOnEvent {
  interested,
  notInterested,
  none,
}

enum GiftSource { post, live, profile }
