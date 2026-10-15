import 'package:foap/util/app_config_constants.dart';

//////******* Do not make any change in this file **********/////////

class NetworkConstantsUtil {
  static String baseUrl = AppConfigConstants.restApiBaseUrl;

  // *************** Login and profile *************//
  static String login = 'users/login';
  static String logout = 'users/logout';

  static String loginWithPhone = 'users/login-with-phonenumber';
  static String loginWithoutPhone = 'users/login-phonenumber-without-otp';

  static String socialLogin = 'users/login-social';
  static String forgotPassword = 'users/forgot-password-request';
  static String resetPassword = 'users/set-new-password';
  static String resendOTP = 'users/resend-otp';
  static String verifyRegistrationOTP = 'users/verify-registration-otp';
  static String verifyFwdPWDOTP = 'users/forgot-password-verify-otp';
  static String verifyChangePhoneOTP = 'users/verify-otp';

  static String updatedDeviceToken = 'users/update-token';
  static String register = 'users/register';
  static String checkUserName = 'users/check-username';
  static String otherUser =
      'users/{{id}}?expand=isFollowing,isFollower,totalFollowing,totalFollower,totalPost,totalWinnerPost,totalReel,totalClub,totalMention,userLiveDetail,giftSummary,userSetting,subscribedStatus,subscriptionPlanUser';

  static String getMyProfile =
      'users/profile?expand=totalFollowing,totalFollower,totalActivePost,totalReel,totalClub,totalMention,userLiveDetail,giftSummary,userSetting,interest,language,featureList,isSubscriptionAllowed,subscriptionPlanUser';
  static String updateUserProfile = 'users/profile-update';
  static String updateProfileImage = 'users/update-profile-image';
  static String updateProfileCoverImage =
      'users/update-profile-cover-image';
  static String updatePassword = 'users/update-password';
  static String updatePhone = 'users/update-mobile';
  static String updateLocation = 'users/update-location';
  static String deleteAccount = 'users/delete-account';
  static String profileCategoryTypes = 'profile-category-types';
  static String userView = 'users/view-counter';
  static String updateAccountPrivacy = 'users/profile-visibility';
  static String updateOnlineStatusSetting =
      'users/show-chat-online-status';

  //*********** User *************//
  static String getSuggestedUsers =
      'users/sugested-user?expand=isFollowing,isFollower,userLiveDetail,subscriptionPlanUser';
  static String followUser = 'followers';
  static String followRequest = 'followers/request';
  static String unfollowUser = 'followers/unfollow';
  static String followMultipleUser = 'followers/follow-multiple';

  static String followers =
      'followers/my-follower?expand=followerUserDetail.isFollowing,followerUserDetail.isFollowing,followerUserDetail.isFollower,followerUserDetail.subscriptionPlanUser&user_id=';
  static String following =
      'followers/my-following?expand=followingUserDetail,followingUserDetail.isFollowing,followingUserDetail.isFollower,followingUserDetail.subscriptionPlanUser&user_id=';
  static String reportUser = 'users/report-user';
  static String blockUser = 'blocked-users';
  static String blockedUsers =
      'blocked-users?expand=blockedUserDetail,userLiveDetail,subscriptionPlanUser';
  static String unBlockUser = 'blocked-users/un-blocked';

  static String findFriends =
      'users/find-friend?expand=isFollowing,isFollower,subscriptionPlanUser&';

  //********************* Misc ******************//
  static String searchHashtag = 'posts/hash-counter-list?hashtag=';
  static String getCountries = 'countries';
  static String getNotifications =
      'notifications?expand=createdByUser,refrenceDetails';
  static String notificationInformation = 'notifications/information';
  static String markNotificationAsRead =
      'notifications/update-read-status';
  static String submitRequest = 'support-requests';
  static String supportRequests = 'support-requests?is_reply=';
  static String supportRequestView = 'support-requests/id';
  static String notificationSettings = 'users/push-notification-status';
  static String followRequests =
      'followers/my-received-following-request?expand=followerUserDetail,followerUserDetail.isFollowing,followerUserDetail.isFollower';
  static String currentLiveUsers =
      'followers/my-following-live?expand=followingUserDetail,followingUserDetail.isFollowing,,followingUserDetail.isFollower,followingUserDetail.userLiveDetail,followingUserDetail.subscriptionPlanUser&user_id=';
  static String acceptFollowRequestString = 'followers/accept-request';
  static String declineFollowRequestString = 'followers/cancel-request';

  static String getSettings = 'settings?expand=featureList';
  static String reportGenericComment = 'reported-contents';
  static String likeComment = 'comments/like';
  static String unLikeComment = 'comments/unlike';

  //********************* Story and Highlights ***********//
  static String stories = 'stories?expand=user,user.userLiveDetail';
  static String addStory = 'stories';
  static String myStories = 'stories/my-story';
  static String myCurrentActiveStories =
      'stories/my-active-story?expand=userStory';
  static String deleteStory = 'stories/';
  static String viewStory = 'stories/view-counter';
  static String storyViewedByUsers =
      'stories/story-view-user?id={{story_id}}&expand=user';
  static String storyDetail = 'stories/';

  static String highlights =
      'highlights?expand=highlightStory,highlightStory.story.user&user_id=';
  static String addStoryToHighlight = 'highlights/add-story';
  static String removeStoryFromHighlight = 'highlights/remove-story';
  static String addHighlight = 'highlights';
  static String updateHighlight = 'highlights/';
  static String deleteHighlight = 'highlights/';

  //********************* Post ***********//
  static String addPost = 'posts';
  static String editPost = 'posts/';

  static String uploadFileImage = 'file-uploads/upload-file';
  static String addCompetitionPost = 'posts/competition-image';
  static String searchPost =
      'posts/search-post?expand=isPin,contentReferenceDetail.categoryDetails,contentReferenceDetail.pollOptions,user.subscribedStatus,user.subscriptionPlanUser,user.isFollowing,user.userLiveDetail,clubDetail.createdByUser,clubDetail.totalJoinedUser,originPost.user,isFavorite,originPost,pollDetails,pollDetails.pollOptions,collaborate.collaboratorDetail';
  static String myPosts =
      'posts/my-post?expand=isPin,contentReferenceDetail.categoryDetails,contentReferenceDetail.pollOptions,user.subscribedStatus,user.subscriptionPlanUser,user.isFollowing,user.userLiveDetail,clubDetail.createdByUser,clubDetail.totalJoinedUser,originPost.user,isFavorite,originPost,pollDetails,pollDetails.pollOptions,collaborate.collaboratorDetail';

  static String postDetail =
      'posts/{id}?expand=isPin,collaborate.collaboratorDetail,contentReferenceDetail.categoryDetails,contentReferenceDetail.pollOptions,user.isFollowing,user.userLiveDetail,clubDetail.createdByUser,clubDetail.totalJoinedUser,originPost.user,isFavorite,originPost,pollDetails,pollDetails.pollOptions';
  static String postDetailByUniqueId =
      'posts/view-by-unique-id?expand=isPin,collaborate.collaboratorDetail,contentReferenceDetail.categoryDetails,contentReferenceDetail.pollOptions,user.isFollowing,user.userLiveDetail,clubDetail.createdByUser,clubDetail.totalJoinedUser,originPost.user,isFavorite,originPost,pollDetails,pollDetails.pollOptions&unique_id=';

  static String searchVideoPost = 'posts/post-video-list';
  static String postView = 'posts/view-counter';

  static String addCollaborate = 'collaborates';
  static String addCollaborationStatus =
      'collaborates/update-invitation-status';

  static String mentionedPosts =
      'posts/my-post-mention-user?expand=user,pollDetails,pollDetails.pollOptions,isPin&user_id=';
  static String likePost = 'posts/like';
  static String unlikePost = 'posts/unlike';
  static String postLikedByUsers =
      'posts/post-like-user-list?post_id={{post_id}}&expand=user.isFollowing,user.subscriptionPlanUser';

  static String savePost = 'favorites/add-favorite';
  static String removeSavedPost = 'favorites/remove-favorite';

  static String reportPost = 'posts/report-post';
  static String deletePost = 'posts/{{id}}';
  static String postInsight = 'posts/insight?post_id=';

  static String getComments = 'posts/comment-list';
  static String addComment = 'posts/add-comment';
  static String deleteComment = 'post-comments/';
  static String reportComment = 'post-comments/report-comment';

  //********************* competition ***********//
  static String getCompetitions =
      'competitions?expand=competitionPosition,post,post.user, post.subscriptionPlanUser';
  static String joinCompetition = 'competitions/join';
  static String getCompetitionDetail =
      'competitions/{{id}}?expand=post,post.user, post.user.subscriptionPlanUser,competitionPosition.post.user,winnerPost';

  //******************** reel ******************//
  static String reelAudioCategories = 'categories/reel-audio';
  static String audios = 'audios?';

  //***********chat***********//
  static String createChatRoom = 'chats/create-room';
  static String updateGroupChatRoom = 'chats/update-room?id=';
  static String getChatRoomDetail =
      'chats/room-detail?room_id={room_id}&expand=createdByUser,chatRoomUser.user,chatRoomUser.user.userLiveDetail';
  static String getChatRooms =
      'chats/room?expand=createdByUser,chatRoomUser,chatRoomUser.user.subscriptionPlanUser,lastMessage,chatRoomUser.user.userLiveDetail';
  static String getPublicChatRooms =
      'chats/open-room?expand=createdByUser,chatRoomUser,chatRoomUser.user.subscriptionPlanUser,lastMessage,chatRoomUser.user.userLiveDetail';

  static String deleteChatRoom = 'chats/delete-room?room_id=';
  static String deleteChatRoomMessages = 'chats/delete-room-chat/';

  static String callHistory =
      'chats/call-history?expand=callerDetail,receiverDetail,receiverDetail.userLiveDetail';
  static String chatHistory =
      'chats/chat-message?expand=chatMessageUser,user.subscriptionPlanUser&room_id={{room_id}}&last_message_id={{last_message_id}}';

  //***********live TVs***********//
  static String getTVCategories =
      'categories/live-tv?expand=liveTv,liveTv.currentViewer';
  static String getTVShows =
      'live-tvs/tv-shows?expand=tvShowEpisode,rating';
  static String getTVShowById =
      'tv-shows/tv-show-details?expand=tvShowEpisode,rating';
  static String getTVShowEpisodes = 'tv-shows/tv-show-episodes?';
  static String tvBanners = 'tv-banners';
  static String liveTvs = 'live-tvs?expand=currentViewer';
  static String getTVChannel =
      'live-tvs/tv-channel-details?id={{channel_id}}';

  static String favTv = 'live-tvs/add-favorite';
  static String unfavTv = 'live-tvs/remove-favorite';
  static String favTvList = 'live-tvs/my-favorite-list';
  static String subscribedTvList = 'live-tvs/my-subscribed-list';
  static String subscribeLiveTv = 'live-tvs/subscribe';
  static String stopWatchingTv = 'live-tvs/stop-viewing';

  //******** Live *********//
  static String liveHistory = 'user-live-histories?expand=giftSummary';
  static String liveGiftsReceived =
      'gifts/live-call-gift-recieved?expand=giftDetail,senderDetail&';
  static String liveCallViewers =
      'chats/live-call-viewer?expand=user.subscriptionPlanUser&live_call_id=';
  static String randomOnlineUser =
      'chats/online-user?profile_category_type=';
  static String liveUsers = 'chats/live-streaming-user';
  static String liveDetailById =
      'user-live-histories/{{live_id}}?expand=giftSummary,userdetails,totalJoinedUsers';
  static String liveDetailByChannel =
      'user-live-histories/detail?expand=giftSummary,userdetails,totalJoinedUsers&id=';

  //***********Podcast***********//
  static String getPodcastCategories =
      'categories/podcast-show?expand=totalPodcastShow';
  static String getHostShowById =
      'podcast-shows/podcast-show-details?expand=podcastShowEpisode';

  static String podcastBanners = 'podcast-banners';
  static String getHosts =
      'podcasts?expand=currentViewer,podcastShow&category_id=&name=';
  static String getPodcastHostDetail =
      'podcasts/podcast-host-details?id={{host_id}}';

  static String getPodcasts = 'podcast-shows?expand=podcastShow';
  static String getPodcastEpisode = 'podcast-shows/podcast-show-episodes?';

  //***********Polls***********//
  static String createPoll = 'polls';

  static String getPolls = 'polls?expand=pollOptions&category_id=&title=';
  static String postPoll = 'poll-question-answers/add-answer';

  //***********Clubs***********//
  /////Dating
  static String interests = 'interests';

  ///////////// Clubs
  static String getClubCategories = 'clubs/category';
  static String createClub = 'clubs';
  static String updateClub = 'clubs/';
  static String deleteClub = 'clubs/';
  static String searchClubs = 'clubs?expand=createdByUser,totalJoinedUser';
  static String clubDetail =
      'clubs/{{club_id}}?expand=totalJoinedUser,createdByUser';
  static String topClubs =
      'clubs/top-club?expand=createdByUser,totalJoinedUser&type=2';
  static String trendingClubs =
      'clubs/top-club?expand=createdByUser,totalJoinedUser&type=1';

  static String joinClub = 'clubs/join';
  static String leaveClub = 'clubs/left';
  static String removeUserFromClub = 'clubs/remove';
  static String clubMembers =
      'clubs/club-joined-user?expand=user.subscriptionPlanUser&id=';
  static String clubJoinInvites =
      'clubs/my-invitation?expand=club.totalJoinedUser,club.createdByUser.subscriptionPlanUser';
  static String replyOnInvitation = 'clubs/invitation-reply';
  static String sendClubInvite = 'clubs/invite';
  static String sendClubJoinRequest = 'clubs/join-request';
  static String clubJoinRequestList =
      'clubs/join-request-list?club_id={{club_id}}&expand=user.subscriptionPlanUser';
  static String clubJoinRequestReply = 'clubs/join-request-reply';

  //***********Events***********//
  // static String joinEvent = 'clubs/join';
  // static String leaveEvent = 'clubs/left';
  static String eventMembers =
      'clubs/club-joined-user?expand=user.subscriptionPlanUser&id=';
  static String eventsCategories = 'categories/event?expand=event.createdByUser';
  static String searchEvents = 'events?expand=createdByUser';
  static String eventCoupons = 'events/coupon';
  static String eventDetails =
      'events/{{id}}?expand=eventTicket,eventOrganisor,createdByUser';
  static String buyTicket = 'events/buy-ticket';
  static String eventBookings = 'events/my-booked-event?';
  static String cancelEventBooking = 'events/cancel-ticket-booking';
  static String giftTicket = 'events/gift-ticket';
  static String eventBookingDetail = 'events/detail-ticket-booking?id=';
  static String linkTicketToBooking = 'events/attach-image-ticket-booking';
  static String userReactionOnEvent = 'user-reactions';

  //***********Events Creation***********//
  static String createEvent = 'events/create-event';
  static String updateEvent = 'events/';
  static String myEventsList = 'events/my-event?expand=createdByUser';
  static String updateEventStatus = 'events/update-status';
  static String usersAttendingEvent = 'user-reactions?type=1&reference_id={{event_id}}&reaction=&expand=user.isFollowing';

  //***********gifts***********//
  static String giftsCategories = 'categories/gift?expand=gift';
  static String giftsByCategory = 'gifts?category_id=';
  static String mostUsedGifts = 'gifts/popular';
  static String sendGift = 'gifts/send-gift';
  static String giftsReceived =
      'gifts/recieved-gift?expand=giftDetail,senderDetail&send_on_type={{send_on_type}}&live_call_id={{live_call_id}}&post_id={{post_id}}';
  static String timelineGifts = 'gifts/timeline-gift';
  static String postGifts =
      'gifts/timeline-gift-recieved?expand=senderDetail,giftTimelineDetail&send_on_type={{send_on_type}}&post_id={{post_id}}';
  static String sendPostGifts = 'gifts/send-timeline-gift';

  //***********verification***********//
  static String requestVerification = 'user-verifications';
  static String requestVerificationHistory = 'user-verifications';
  static String cancelVerification = 'user-verifications/cancel';

  //***********FAQ***********//
  static String getFAQs = 'faqs';

  //***********Payment***********//
  static String createPaymentIntent = 'payments/payment-intent';
  static String getPaypalClientToken = 'payments/paypal-client-token';
  static String submitPaypalPayment = 'payments/paypal-payment';
  static String updatePaymentDetail = 'users/update-payment-detail';
  static String withdrawHistory = 'payments/withdrawal-history';
  static String withdrawalRequest = 'payments/withdrawal';
  static String transactionHistory = 'payments/payment-history?';

  //***********Package and coins***********//
  static String getPackages = 'packages';
  static String subscribePackage = 'payments/package-subscription';
  static String redeemCoins = 'payments/redeem-coin';
  static String rewardedAdCoins = 'posts/promotion-ad-view';

  //***********Dating***********//
  static String addUserPreference = 'datings/add-user-preference';
  static String getUserPreference =
      'datings/preference-profile?expand=preferenceInterest,preferenceLanguage';
  static String getDatingProfiles = 'datings/preference-profile-match';
  static String profileLike = 'datings/profile-action-like';
  static String profileSkip = 'datings/profile-action-skip';
  static String undoProfileLike = 'datings/profile-action-remove';
  static String matchedProfiles = 'datings/profile-matching';
  static String likeProfiles = 'datings/profile-like-by-other-users';
  static String getLanguages = 'languages';

  //*********** Misc ***********//
  static String postRating = 'ratings';
  static String ratingList =
      'ratings?type={{type}}&reference_id={{reference_id}}&expand=user';
  static String addPinContent = 'pins';
  static String removePinContent = 'pins/';

  //*********** Fund raising ***********//
  static String campaignCategories =
      'categories/campaign?expand=campaignList';
  static String campaignsList =
      'campaigns?expand=donorsDetails,categoryDetails';
  static String favCampaignsList =
      'campaigns/my-favorite-list?expand=donorsDetails,categoryDetails';
  static String campaignComments =
      'campaigns/comment-list?expand=user.subscriptionPlanUser,isLike,totalChildComment,childCommentDetail.isLike,childCommentDetail.user';
  static String addCommentOnCampaign = 'campaigns/add-comment';
  static String deleteCampaignComment = 'campaigns/delete-comment';
  static String favCampaign = 'campaigns/add-favorite';
  static String unFavCampaign = 'campaigns/remove-favorite';
  static String makeDonationPayment = 'campaigns/payment';
  static String donorsList =
      'campaigns/donors-list?expand=userDetail.isFollowing,userDetail.subscriptionPlanUser,userDetail.totalFollowing,userDetail.totalFollower,campaignDetails&user_id=&transaction_type=&campaign_id=';

  //*********** Coupons ***********//
  static String businessCategories =
      'categories/business-category?expand=business,coupon';
  static String searchBusiness = 'businesses?expand=coupon';
  static String offersList = 'coupons?expand=business';
  static String offerCommentsList =
      'coupons/comment-list?expand=user,isLike,coupon,totalChildComment,childCommentDetail.isLike,childCommentDetail.user.subscriptionPlanUser';
  static String addCommentOnOffer = 'coupons/add-comment';
  static String deleteOfferComment = 'coupons/delete-comment';
  static String getFavOffer = 'coupons/my-favorite-list?expand=business';
  static String favOffer = 'coupons/add-favorite';
  static String unFavOffer = 'coupons/remove-favorite';

  //*********** Promotion ***********//
  static String searchLocation = 'countries/search-location?name=';
  static String createAudiences = 'audiences';
  static String getAudiences =
      'audiences?expand=interestDetails,locationDetails';
  static String createPromotions = 'post-promotions';
  static String getPromotedPosts =
      'posts/post-promotion-ad?expand=user,postPromotionData,user,postPromotionData,contentReferenceDetail.categoryDetails,contentReferenceDetail.pollOptions,user.isFollowing,user.subscriptionPlanUser,user.userLiveDetail,clubDetail.createdByUser,clubDetail.totalJoinedUser,originPost.user,isFavorite,originPost,pollDetails,pollDetails.pollOptions';

  //*********** Shop ***********//
  static String postAd = "ads";
  static String updateAd = "ads/";
  static String myAds = "ads/my-ad?expand=user.subscriptionPlanUser";
  static String adDetail = "ads/";
  static String updateAdStatus = "ads/update-status";
  static String searchAds =
      "ads/ad-search?expand=user.subscriptionPlanUser,facility";
  static String reportAd = "ads/report-ad";
  static String shopProductAddTofav = "ad-favorites";
  static String shopProductRemoveFromfav = "ad-favorites/delete-list";
  static String promotionalAds = "promotional-ads";
  static String shopFavAds =
      "ad-favorites?expand=user.subscriptionPlanUser";
  static String getShopCategories =
      "categories/all?expand=subCategory.total_ads&type=9&name";

  //*********** Job ***********//
  static String jobCategories = "categories/job?expand=totalJob";
  static String jobsList = "jobs?";
  static String applyJob = "job-applications";
  static String appliedJobs = "job-applications";
  static String updateJobApplication = "job-applications/";
  static String deleteJobApplication = "job-applications/";

//*********** Subscription ***********//
  static String getSubscriptionPlans = "subscriptions/subscription-plan";
  static String setSubscriptionPlanCost = "subscriptions/add-plan";
  static String subscribeUser = "subscriptions";
  static String subscribersList =
      "subscriptions/subscriber-list?user_id={{user_id}}&expand=subscribedPlanStatus,subscriberDetail,subscriberDetail.subscribedStatus";
  static String mySubscription =
      "subscriptions/my-subscription-list?expand=subscribedPlanStatus,subscriptionUserDetail,subscriptionUserDetail.subscribedStatus";
}
