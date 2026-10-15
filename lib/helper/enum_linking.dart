import 'package:foap/helper/imports/common_import.dart';

int postTypeValueFrom(PostCategory postType) {
  switch (postType) {
    case PostCategory.basic:
      return 1;
    case PostCategory.competition:
      return 2;
    case PostCategory.club:
      return 3;
    case PostCategory.reel:
      return 4;
    case PostCategory.reshare:
      return 5;
    case PostCategory.event:
      return 6;
    case PostCategory.fundRaising:
      return 7;
  }
}

int postContentTypeIdFrom(PostContentType contentType) {
  switch (contentType) {
    case PostContentType.text:
      return 1;
    case PostContentType.media:
      return 2;
    case PostContentType.location:
      return 3;
    case PostContentType.poll:
      return 4;
    case PostContentType.competitionAdded:
      return 5;
    case PostContentType.event:
      return 6;
    case PostContentType.fundRaising:
      return 7;
    case PostContentType.job:
      return 8;
    case PostContentType.competitionResultDeclared:
      return 9;
    case PostContentType.offer:
      return 10;
    case PostContentType.donation:
      return 11;
    case PostContentType.classified:
      return 12;
    case PostContentType.club:
      return 13;
    case PostContentType.openGroup:
      return 14;
  }
}

PostContentType postContentTypeValueFrom(int contentType) {
  switch (contentType) {
    case 1:
      return PostContentType.text;
    case 2:
      return PostContentType.media;
    case 3:
      return PostContentType.location;
    case 4:
      return PostContentType.poll;
    case 5:
      return PostContentType.competitionAdded;
    case 6:
      return PostContentType.event;
    case 7:
      return PostContentType.fundRaising;
    case 8:
      return PostContentType.job;
    case 9:
      return PostContentType.competitionResultDeclared;
    case 10:
      return PostContentType.offer;
    case 11:
      return PostContentType.donation;
    case 12:
      return PostContentType.classified;
    case 13:
      return PostContentType.club;
    case 14:
      return PostContentType.openGroup;
  }
  return PostContentType.text;
}

int mediaTypeIdFromMediaType(GalleryMediaType type) {
  switch (type) {
    case GalleryMediaType.photo:
      return 1;
    case GalleryMediaType.video:
      return 2;
    case GalleryMediaType.audio:
      return 3;
    case GalleryMediaType.gif:
      return 4;
    default:
      return 1;
  }
}

int itemViewSourceToId(ItemViewSource source) {
  switch (source) {
    case ItemViewSource.normal:
      return 1;
    case ItemViewSource.promotion:
      return 2;
  }
}

int userViewSourceTypeToId(UserViewSourceType source) {
  switch (source) {
    case UserViewSourceType.post:
      return 1;
    case UserViewSourceType.reel:
      return 2;
    case UserViewSourceType.story:
      return 2;
  }
}

PaymentType paymentTypeFromId(int id) {
  switch (id) {
    case 1:
      return PaymentType.package;
    case 2:
      return PaymentType.award;
    case 3:
      return PaymentType.withdrawal;
    case 4:
      return PaymentType.withdrawalRefund;
    case 5:
      return PaymentType.liveTvSubscribe;
    case 6:
      return PaymentType.giftSent;
    case 7:
      return PaymentType.redeemCoin;
    case 8:
      return PaymentType.eventTicket;
    case 9:
      return PaymentType.eventTicketRefund;
    case 10:
      return PaymentType.datingSubscription;
    case 11:
      return PaymentType.promotion;
    case 12:
      return PaymentType.promotionRefund;
    case 15:
      return PaymentType.fundRaising;
    case 16:
      return PaymentType.featureAd;
    case 17:
      return PaymentType.bannerAd;
    case 20:
      return PaymentType.subscription;
  }
  return PaymentType.package;
}

String paymentTypeStringFromId(PaymentType type) {
  switch (type) {
    case PaymentType.package:
      return boughtCoinsString.tr;
    case PaymentType.award:
      return awardedString.tr;
    case PaymentType.withdrawal:
      return withdrawalString.tr;
    case PaymentType.withdrawalRefund:
      return withdrawalRefundString.tr;
    case PaymentType.liveTvSubscribe:
      return subscribedTvString.tr;
    case PaymentType.giftSent:
      return giftSentString.tr;
    case PaymentType.giftReceived:
      return giftsReceivedString.tr;
    case PaymentType.redeemCoin:
      return redeemString.tr;
    case PaymentType.eventTicket:
      return evenTicketString.tr;
    case PaymentType.eventTicketRefund:
      return evenTicketRefundString.tr;
    case PaymentType.datingSubscription:
      return datingSubscriptionString.tr;
    case PaymentType.promotion:
      return postPromotionString.tr;
    case PaymentType.promotionRefund:
      return postPromotionRefundString.tr;
    case PaymentType.fundRaising:
      return donationString.tr;
    case PaymentType.featureAd:
      return promotedAdString.tr;
    case PaymentType.bannerAd:
      return promotedAdString.tr;
    case PaymentType.subscription:
      return subscriptionString.tr;
  }
}

PaymentMode paymentModeFromId(int id) {
  switch (id) {
    case 1:
      return PaymentMode.inAppPurchase;
    case 2:
      return PaymentMode.paypal;
    case 3:
      return PaymentMode.wallet;
    case 4:
      return PaymentMode.stripe;
    case 5:
      return PaymentMode.razorpay;
    case 9:
      return PaymentMode.flutterWave;
  }
  return PaymentMode.inAppPurchase;
}

TransactionType transactionTypeFromId(int id) {
  if (id == 1) {
    return TransactionType.credit;
  }
  return TransactionType.debit;
}

TransactionMedium transactionMediumTypeFromId(int id) {
  if (id == 1) {
    return TransactionMedium.money;
  }
  return TransactionMedium.coin;
}

int messageTypeId(MessageContentType type) {
  switch (type) {
    case MessageContentType.text:
      return 1;
    case MessageContentType.photo:
      return 2;
    case MessageContentType.video:
      return 3;
    case MessageContentType.audio:
      return 4;
    case MessageContentType.gif:
      return 5;
    case MessageContentType.sticker:
      return 6;
    case MessageContentType.contact:
      return 7;
    case MessageContentType.location:
      return 8;
    case MessageContentType.reply:
      return 9;
    case MessageContentType.forward:
      return 10;
    case MessageContentType.post:
      return 11;
    case MessageContentType.story:
      return 12;
    case MessageContentType.drawing:
      return 13;
    case MessageContentType.profile:
      return 14;
    case MessageContentType.group:
      return 15;
    case MessageContentType.file:
      return 16;
    case MessageContentType.textReplyOnStory:
      return 17;
    case MessageContentType.reactedOnStory:
      return 18;
    case MessageContentType.groupAction:
      return 100;
    case MessageContentType.gift:
      return 200;
  }
}

int uploadMediaTypeId(UploadMediaType type) {
  switch (type) {
    case UploadMediaType.shop:
      return 1;
    case UploadMediaType.storyOrHighlights:
      return 3;
    case UploadMediaType.chat:
      return 5;
    case UploadMediaType.club:
      return 5;
    case UploadMediaType.post:
      return 7;
    case UploadMediaType.verification:
      return 12;
    case UploadMediaType.event:
      return 13;
    case UploadMediaType.uploadResume:
      return 28;
  }
}

int liveViewerRole(LiveUserRole role) {
  switch (role) {
    case LiveUserRole.viewer:
      return 2;
    case LiveUserRole.moderator:
      return 3;
    case LiveUserRole.host:
      return 1;
  }
}

SMSGateway smsGatewayType(int id) {
  switch (id) {
    case 1:
      return SMSGateway.twilio;
    case 2:
      return SMSGateway.sms91;
    case 3:
      return SMSGateway.firebase;
    default:
      return SMSGateway.twilio;
  }
}

SubscribedStatus subscribedStatusType(int id) {
  switch (id) {
    case 0:
      return SubscribedStatus.notSubscribed;
    case 1:
      return SubscribedStatus.subscribed;
    case 2:
      return SubscribedStatus.expired;
    default:
      return SubscribedStatus.notSubscribed;
  }
}

int pinContentTypeId(PinContentType type) {
  switch (type) {
    case PinContentType.post:
      return 1;
    default:
      return 2;
  }
}

CollaborationStatusType collaborationStatusType(int id) {
  switch (id) {
    case 0:
      return CollaborationStatusType.deleted;
    case 1:
      return CollaborationStatusType.pending;
    case 2:
      return CollaborationStatusType.rejected;
    case 4:
      return CollaborationStatusType.cancelled;
    default:
      return CollaborationStatusType.accepted;
  }
}

int collaborationStatusTypeId(CollaborationStatusType type) {
  switch (type) {
    case CollaborationStatusType.deleted:
      return 0;
    case CollaborationStatusType.pending:
      return 1;
    case CollaborationStatusType.rejected:
      return 2;
    case CollaborationStatusType.cancelled:
      return 4;
    default:
      return 3;
  }
}

int eventStatusToId(EventStatus status) {
  switch (status) {
    case EventStatus.upcoming:
      return 1;
    case EventStatus.active:
      return 2;
    case EventStatus.completed:
      return 3;
    case EventStatus.cancelled:
      return 9;
  }
}

EventStatus eventStatusType(int id) {
  switch (id) {
    case 1:
      return EventStatus.upcoming;
    case 2:
      return EventStatus.active;
    case 3:
      return EventStatus.completed;
    default:
      return EventStatus.cancelled;
  }
}

UserRole userRoleType(int id) {
  switch (id) {
    case 3:
      return UserRole.user;

    default:
      return UserRole.user;
  }
}

GiftSource giftSourceType(int id) {
  switch (id) {
    case 1:
      return GiftSource.live;
    case 2:
      return GiftSource.profile;
    case 3:
      return GiftSource.post;
    default:
      return GiftSource.profile;
  }
}

int giftSourceId(GiftSource type) {
  switch (type) {
    case GiftSource.live:
      return 1;
    case GiftSource.profile:
      return 2;
    case GiftSource.post:
      return 3;
  }
}

ReactionOnEvent reactionOnEventType(int id) {
  switch (id) {
    case 0:
      return ReactionOnEvent.none;
    case 1:
      return ReactionOnEvent.interested;
    case 2:
      return ReactionOnEvent.notInterested;
    default:
      return ReactionOnEvent.none;
  }
}

int reactionOnEventTypeId(ReactionOnEvent type) {
  switch (type) {
    case ReactionOnEvent.none:
      return 0;
    case ReactionOnEvent.interested:
      return 1;
    case ReactionOnEvent.notInterested:
      return 2;
  }
}
