# Telegram API 完整功能清单

**基于**: Telegram Android 客户端源码 (API Layer 221)

**总计**: 601 个 TL 对象

**模块数**: 142 个

---

## MESSAGES (259 个方法)

- `messages_acceptEncryption`
- `messages_acceptUrlAuth`
- `messages_addChatUser`
- `messages_affectedFoundMessages`
- `messages_affectedHistory`
- `messages_affectedMessages`
- `messages_appendTodoList`
- `messages_archivedStickers`
- `messages_botApp`
- `messages_botCallbackAnswer`
- `messages_chatAdminsWithInvites`
- `messages_chatFull`
- `messages_chatInviteImporters`
- `messages_checkChatInvite`
- `messages_checkHistoryImport`
- `messages_checkHistoryImportPeer`
- `messages_checkQuickReplyShortcut`
- `messages_checkedHistoryImportPeer`
- `messages_clearAllDrafts`
- `messages_clearRecentReactions`
- `messages_clearRecentStickers`
- `messages_clickSponsoredMessage`
- `messages_createChat`
- `messages_deleteChat`
- `messages_deleteChatUser`
- `messages_deleteExportedChatInvite`
- `messages_deleteHistory`
- `messages_deleteMessages`
- `messages_deletePhoneCallHistory`
- `messages_deleteQuickReplyMessages`
- `messages_deleteQuickReplyShortcut`
- `messages_deleteRevokedExportedChatInvites`
- `messages_deleteSavedHistory`
- `messages_deleteScheduledMessages`
- `messages_dialogFilters`
- `messages_discardEncryption`
- `messages_discussionMessage`
- `messages_editChatAbout`
- `messages_editChatAdmin`
- `messages_editChatDefaultBannedRights`
- `messages_editChatPhoto`
- `messages_editChatTitle`
- `messages_editExportedChatInvite`
- `messages_editMessage`
- `messages_editQuickReplyShortcut`
- `messages_emojiGameOutcome`
- `messages_exportChatInvite`
- `messages_exportedChatInvites`
- `messages_faveSticker`
- `messages_forumTopics`
- `messages_forwardMessage`
- `messages_forwardMessages`
- `messages_getAdminsWithInvites`
- `messages_getAllChats`
- `messages_getAllDrafts`
- `messages_getAllStickers`
- `messages_getArchivedStickers`
- `messages_getAttachMenuBot`
- `messages_getAttachMenuBots`
- `messages_getAttachedStickers`
- `messages_getAvailableEffects`
- `messages_getAvailableReactions`
- `messages_getBotApp`
- `messages_getBotCallbackAnswer`
- `messages_getChatInviteImporters`
- `messages_getChats`
- `messages_getCommonChats`
- `messages_getCustomEmojiDocuments`
- `messages_getDefaultHistoryTTL`
- `messages_getDefaultTagReactions`
- `messages_getDhConfig`
- `messages_getDialogFilters`
- `messages_getDialogUnreadMarks`
- `messages_getDialogs`
- `messages_getDiscussionMessage`
- `messages_getDocumentByHash`
- `messages_getEmojiGroups`
- `messages_getEmojiKeywords`
- `messages_getEmojiKeywordsDifference`
- `messages_getEmojiKeywordsLanguages`
- `messages_getEmojiProfilePhotoGroups`
- `messages_getEmojiStatusGroups`
- `messages_getEmojiStickerGroups`
- `messages_getEmojiStickers`
- `messages_getEmojiURL`
- `messages_getExportedChatInvite`
- `messages_getExportedChatInvites`
- `messages_getExtendedMedia`
- `messages_getFavedStickers`
- `messages_getFeaturedEmojiStickers`
- `messages_getFeaturedStickers`
- `messages_getFullChat`
- `messages_getGameHighScores`
- `messages_getHistory`
- `messages_getInlineBotResults`
- `messages_getInlineGameHighScores`
- `messages_getMaskStickers`
- `messages_getMessageEditData`
- `messages_getMessageReactionsList`
- `messages_getMessageReadParticipants`
- `messages_getMessages`
- `messages_getMessagesReactions`
- `messages_getMessagesViews`
- `messages_getMyStickers`
- `messages_getOldFeaturedStickers`
- `messages_getOnlines`
- `messages_getOutboxReadDate`
- `messages_getPaidReactionPrivacy`
- `messages_getPeerDialogs`
- `messages_getPeerSettings`
- `messages_getPinnedDialogs`
- `messages_getPinnedSavedDialogs`
- `messages_getPollResults`
- `messages_getPollVotes`
- `messages_getPreparedInlineMessage`
- `messages_getQuickReplies`
- `messages_getQuickReplyMessages`
- `messages_getRecentLocations`
- `messages_getRecentReactions`
- `messages_getRecentStickers`
- `messages_getReplies`
- `messages_getSavedDialogs`
- `messages_getSavedDialogsByID`
- `messages_getSavedGifs`
- `messages_getSavedHistory`
- `messages_getSavedReactionTags`
- `messages_getScheduledHistory`
- `messages_getScheduledMessages`
- `messages_getSearchCounters`
- `messages_getSearchResultsCalendar`
- `messages_getSearchResultsPositions`
- `messages_getSponsoredMessages`
- `messages_getStatsURL`
- `messages_getStickerSet`
- `messages_getStickers`
- `messages_getSuggestedDialogFilters`
- `messages_getTopReactions`
- `messages_getUnreadMentions`
- `messages_getUnreadReactions`
- `messages_getWebPage`
- `messages_getWebViewResult`
- `messages_hideAllChatJoinRequests`
- `messages_hideChatJoinRequest`
- `messages_hidePeerSettingsBar`
- `messages_highScores`
- `messages_historyImport`
- `messages_historyImportParsed`
- `messages_importChatInvite`
- `messages_inactiveChats`
- `messages_initHistoryImport`
- `messages_installStickerSet`
- `messages_invitedUsers`
- `messages_markDialogUnread`
- `messages_messageEditData`
- `messages_messageEmpty`
- `messages_messageReactionsList`
- `messages_messageViews`
- `messages_migrateChat`
- `messages_myStickers`
- `messages_peerDialogs`
- `messages_peerSettings`
- `messages_preparedInlineMessage`
- `messages_prolongWebView`
- `messages_rateTranscribedAudio`
- `messages_readDiscussion`
- `messages_readEncryptedHistory`
- `messages_readFeaturedStickers`
- `messages_readHistory`
- `messages_readMentions`
- `messages_readMessageContents`
- `messages_readReactions`
- `messages_readSavedHistory`
- `messages_receivedMessages`
- `messages_receivedQueue`
- `messages_reorderPinnedDialogs`
- `messages_reorderPinnedSavedDialogs`
- `messages_reorderQuickReplies`
- `messages_reorderStickerSets`
- `messages_report`
- `messages_reportEncryptedSpam`
- `messages_reportReaction`
- `messages_reportSpam`
- `messages_reportSponsoredMessage`
- `messages_requestAppWebView`
- `messages_requestEncryption`
- `messages_requestMainWebView`
- `messages_requestSimpleWebView`
- `messages_requestUrlAuth`
- `messages_requestWebView`
- `messages_saveDefaultSendAs`
- `messages_saveDraft`
- `messages_saveGif`
- `messages_saveRecentSticker`
- `messages_search`
- `messages_searchCounter`
- `messages_searchCustomEmoji`
- `messages_searchEmojiStickerSets`
- `messages_searchGlobal`
- `messages_searchResultsCalendar`
- `messages_searchResultsPositions`
- `messages_searchStickerSets`
- `messages_searchStickers`
- `messages_sendBotRequestedPeer`
- `messages_sendEncrypted`
- `messages_sendEncryptedFile`
- `messages_sendEncryptedMultiMedia`
- `messages_sendEncryptedService`
- `messages_sendInlineBotResult`
- `messages_sendMedia`
- `messages_sendMessage`
- `messages_sendMultiMedia`
- `messages_sendPaidReaction`
- `messages_sendQuickReplyMessages`
- `messages_sendReaction`
- `messages_sendScheduledMessages`
- `messages_sendScreenshotNotification`
- `messages_sendVote`
- `messages_sendWebViewData`
- `messages_sendWebViewResultMessage`
- `messages_setBotCallbackAnswer`
- `messages_setChatAvailableReactions`
- `messages_setChatWallPaper`
- `messages_setDefaultHistoryTTL`
- `messages_setDefaultReaction`
- `messages_setEncryptedTyping`
- `messages_setGameScore`
- `messages_setHistoryTTL`
- `messages_setInlineGameScore`
- `messages_setTyping`
- `messages_setWebViewResult`
- `messages_startBot`
- `messages_startHistoryImport`
- `messages_toggleBotInAttachMenu`
- `messages_toggleDialogFilterTags`
- `messages_toggleDialogPin`
- `messages_toggleNoForwards`
- `messages_togglePaidReactionPrivacy`
- `messages_togglePeerTranslations`
- `messages_toggleSavedDialogPin`
- `messages_toggleStickerSets`
- `messages_toggleSuggestedPostApproval`
- `messages_toggleTodoCompleted`
- `messages_transcribeAudio`
- `messages_transcribedAudio`
- `messages_translateResult`
- `messages_translateText`
- `messages_uninstallStickerSet`
- `messages_unpinAllMessages`
- `messages_updateDialogFilter`
- `messages_updateDialogFiltersOrder`
- `messages_updatePinnedMessage`
- `messages_updateSavedReactionTag`
- `messages_uploadEncryptedFile`
- `messages_uploadImportedMedia`
- `messages_uploadMedia`
- `messages_viewSponsoredMessage`
- `messages_votesList`
- `messages_webPage`
- `messages_webViewResult`

## CHANNELS (60 个方法)

- `channels_adminLogResults`
- `channels_channelParticipant`
- `channels_checkSearchPostsFlood`
- `channels_checkUsername`
- `channels_convertToGigagroup`
- `channels_createChannel`
- `channels_deactivateAllUsernames`
- `channels_deleteChannel`
- `channels_deleteHistory`
- `channels_deleteMessages`
- `channels_deleteParticipantHistory`
- `channels_editAdmin`
- `channels_editBanned`
- `channels_editCreator`
- `channels_editLocation`
- `channels_editPhoto`
- `channels_editTitle`
- `channels_exportMessageLink`
- `channels_getAdminLog`
- `channels_getAdminedPublicChannels`
- `channels_getChannelRecommendations`
- `channels_getChannels`
- `channels_getFullChannel`
- `channels_getGroupsForDiscussion`
- `channels_getInactiveChannels`
- `channels_getMessageAuthor`
- `channels_getMessages`
- `channels_getParticipant`
- `channels_getParticipants`
- `channels_getSendAs`
- `channels_inviteToChannel`
- `channels_joinChannel`
- `channels_leaveChannel`
- `channels_readHistory`
- `channels_readMessageContents`
- `channels_reorderUsernames`
- `channels_reportAntiSpamFalsePositive`
- `channels_reportSpam`
- `channels_restrictSponsoredMessages`
- `channels_searchPosts`
- `channels_sendAsPeers`
- `channels_setBoostsToUnblockRestrictions`
- `channels_setDiscussionGroup`
- `channels_setEmojiStickers`
- `channels_setMainProfileTab`
- `channels_setStickers`
- `channels_toggleAntiSpam`
- `channels_toggleAutotranslation`
- `channels_toggleForum`
- `channels_toggleJoinRequest`
- `channels_toggleJoinToSend`
- `channels_toggleParticipantsHidden`
- `channels_togglePreHistoryHidden`
- `channels_toggleSignatures`
- `channels_toggleSlowMode`
- `channels_toggleUsername`
- `channels_toggleViewForumAsMessages`
- `channels_updateColor`
- `channels_updateEmojiStatus`
- `channels_updateUsername`

## HELP (34 个方法)

- `help_acceptTermsOfService`
- `help_country`
- `help_countryCode`
- `help_dismissSuggestion`
- `help_editUserInfo`
- `help_getAppChangelog`
- `help_getAppConfig`
- `help_getAppUpdate`
- `help_getConfig`
- `help_getCountriesList`
- `help_getDeepLinkInfo`
- `help_getInviteText`
- `help_getNearestDc`
- `help_getPassportConfig`
- `help_getPeerColors`
- `help_getPeerProfileColors`
- `help_getPremiumPromo`
- `help_getPromoData`
- `help_getRecentMeUrls`
- `help_getSupport`
- `help_getSupportName`
- `help_getTermsOfServiceUpdate`
- `help_getTimezonesList`
- `help_getUserInfo`
- `help_hidePromoData`
- `help_inviteText`
- `help_peerColorOption`
- `help_premiumPromo`
- `help_recentMeUrls`
- `help_saveAppLog`
- `help_setBotUpdatesStatus`
- `help_support`
- `help_supportName`
- `help_termsOfService`

## CONTACTS (27 个方法)

- `contacts_acceptContact`
- `contacts_addContact`
- `contacts_block`
- `contacts_blockFromReplies`
- `contacts_deleteByPhones`
- `contacts_deleteContacts`
- `contacts_exportContactToken`
- `contacts_found`
- `contacts_getBlocked`
- `contacts_getContacts`
- `contacts_getSponsoredPeers`
- `contacts_getStatuses`
- `contacts_getTopPeers`
- `contacts_importCard`
- `contacts_importContactToken`
- `contacts_importContacts`
- `contacts_importedContacts`
- `contacts_link_layer101`
- `contacts_resetSaved`
- `contacts_resetTopPeerRating`
- `contacts_resolvePhone`
- `contacts_resolveUsername`
- `contacts_resolvedPeer`
- `contacts_search`
- `contacts_setBlocked`
- `contacts_toggleTopPeers`
- `contacts_unblock`

## PAYMENTS (26 个方法)

- `payments_applyGiftCode`
- `payments_assignPlayMarketTransaction`
- `payments_bankCardData`
- `payments_canPurchaseStore`
- `payments_checkGiftCode`
- `payments_checkedGiftCode`
- `payments_clearSavedInfo`
- `payments_exportInvoice`
- `payments_exportedInvoice`
- `payments_getBankCardData`
- `payments_getGiveawayInfo`
- `payments_getPaymentReceipt`
- `payments_getPremiumGiftCodeOptions`
- `payments_getSavedInfo`
- `payments_getStarsRevenueAdsAccountUrl`
- `payments_getStarsRevenueStats`
- `payments_getStarsRevenueWithdrawalUrl`
- `payments_launchPrepaidGiveaway`
- `payments_requestRecurringPayment`
- `payments_savedInfo`
- `payments_sendPaymentForm`
- `payments_starsRevenueAdsAccountUrl`
- `payments_starsRevenueStats`
- `payments_starsRevenueWithdrawalUrl`
- `payments_validateRequestedInfo`
- `payments_validatedRequestedInfo`

## AUTH (23 个方法)

- `auth_acceptLoginToken`
- `auth_cancelCode`
- `auth_checkPassword`
- `auth_checkRecoveryPassword`
- `auth_exportAuthorization`
- `auth_exportLoginToken`
- `auth_exportedAuthorization`
- `auth_importAuthorization`
- `auth_importLoginToken`
- `auth_logOut`
- `auth_loggedOut`
- `auth_passwordRecovery`
- `auth_recoverPassword`
- `auth_reportMissingCode`
- `auth_requestFirebaseSms`
- `auth_requestPasswordRecovery`
- `auth_resendCode`
- `auth_resetAuthorizations`
- `auth_resetLoginEmail`
- `auth_sendCode`
- `auth_signIn`
- `auth_signInOld`
- `auth_signUp`

## STICKERS (12 个方法)

- `stickers_addStickerToSet`
- `stickers_changeSticker`
- `stickers_changeStickerPosition`
- `stickers_checkShortName`
- `stickers_createStickerSet`
- `stickers_deleteStickerSet`
- `stickers_removeStickerFromSet`
- `stickers_renameStickerSet`
- `stickers_replaceSticker`
- `stickers_setStickerSetThumb`
- `stickers_suggestShortName`
- `stickers_suggestedShortName`

## UPLOAD (9 个方法)

- `upload_getCdnFile`
- `upload_getCdnFileHashes`
- `upload_getFile`
- `upload_getFileHashes`
- `upload_getWebFile`
- `upload_reuploadCdnFile`
- `upload_saveBigFilePart`
- `upload_saveFilePart`
- `upload_webFile`

## PHOTOS (6 个方法)

- `photos_deletePhotos`
- `photos_getUserPhotos`
- `photos_photo`
- `photos_updateProfilePhoto`
- `photos_uploadContactProfilePhoto`
- `photos_uploadProfilePhoto`

## LANGPACK (5 个方法)

- `langpack_getDifference`
- `langpack_getLangPack`
- `langpack_getLanguage`
- `langpack_getLanguages`
- `langpack_getStrings`

## USERS (4 个方法)

- `users_getFullUser`
- `users_getUsers`
- `users_suggestBirthday`
- `users_userFull`

## UPDATES (4 个方法)

- `updates_getChannelDifference`
- `updates_getDifference`
- `updates_getState`
- `updates_state`

## FOLDERS (2 个方法)

- `folders_deleteFolder`
- `folders_editPeerFolders`

## ACCOUNT (2 个方法)

- `account_saveMusic`
- `account_setMainProfileTab`

## CHATBANNEDRIGHTS (1 个方法)

- `chatBannedRights_chatBannedRights`

## EMOJIKEYWORDSDIFFERENCE (1 个方法)

- `emojiKeywordsDifference_emojiKeywordsDifference`

## PREMIUMSUBSCRIPTIONOPTION (1 个方法)

- `premiumSubscriptionOption_premiumSubscriptionOption`

## PREMIUMGIFTOPTION (1 个方法)

- `premiumGiftOption_premiumGiftOption`

## ERROR (1 个方法)

- `error_error`

## STATSURL (1 个方法)

- `statsURL_statsURL`

## POPULARCONTACT (1 个方法)

- `popularContact_popularContact`

## CONTACTSTATUS (1 个方法)

- `contactStatus_contactStatus`

## CHANNELBANNEDRIGHTS (1 个方法)

- `channelBannedRights_layer92`

## FOLDER (1 个方法)

- `folder_folder`

## PAYMENTFORMMETHOD (1 个方法)

- `paymentFormMethod_paymentFormMethod`

## LABELEDPRICE (1 个方法)

- `labeledPrice_labeledPrice`

## INPUTSTICKERSETITEM (1 个方法)

- `inputStickerSetItem_inputStickerSetItem`

## LANGPACKDIFFERENCE (1 个方法)

- `langPackDifference_langPackDifference`

## CHATADMINRIGHTS (1 个方法)

- `chatAdminRights_chatAdminRights`

## POLLANSWERVOTERS (1 个方法)

- `pollAnswerVoters_pollAnswerVoters`

## AUTHORIZATION (1 个方法)

- `authorization_authorization`

## CHANNELADMINLOGEVENT (1 个方法)

- `channelAdminLogEvent_channelAdminLogEvent`

## LANGPACKLANGUAGE (1 个方法)

- `langPackLanguage_langPackLanguage`

## CHATINVITEIMPORTER (1 个方法)

- `chatInviteImporter_chatInviteImporter`

## READPARTICIPANTDATE (1 个方法)

- `readParticipantDate_readParticipantDate`

## INPUTPHONECONTACT (1 个方法)

- `inputPhoneContact_inputPhoneContact`

## PAGECAPTION (1 个方法)

- `pageCaption_pageCaption`

## PAGETABLECELL (1 个方法)

- `pageTableCell_pageTableCell`

## INPUTSECUREVALUE (1 个方法)

- `inputSecureValue_inputSecureValue`

## SECUREVALUEHASH (1 个方法)

- `secureValueHash_secureValueHash`

## MESSAGEVIEWS (1 个方法)

- `messageViews_messageViews`

## INPUTPEERNOTIFYSETTINGS (1 个方法)

- `inputPeerNotifySettings_inputPeerNotifySettings`

## CODESETTINGS (1 个方法)

- `codeSettings_codeSettings`

## NULL (1 个方法)

- `null_null`

## TOPPEERCATEGORYPEERS (1 个方法)

- `topPeerCategoryPeers_topPeerCategoryPeers`

## KEYBOARDBUTTONROW (1 个方法)

- `keyboardButtonRow_keyboardButtonRow`

## INPUTAPPEVENT (1 个方法)

- `inputAppEvent_inputAppEvent`

## SECUREVALUE (1 个方法)

- `secureValue_secureValue`

## EXPORTEDCONTACTTOKEN (1 个方法)

- `exportedContactToken_exportedContactToken`

## BOTCOMMAND (1 个方法)

- `botCommand_botCommand`

## RECENTSTORY (1 个方法)

- `recentStory_recentStory`

## INVOICE (1 个方法)

- `invoice_invoice`

## INPUTWEBDOCUMENT (1 个方法)

- `inputWebDocument_inputWebDocument`

## SAVEDREACTIONTAG (1 个方法)

- `savedReactionTag_savedReactionTag`

## OUTBOXREADDATE (1 个方法)

- `outboxReadDate_outboxReadDate`

## EXPORTEDMESSAGELINK (1 个方法)

- `exportedMessageLink_exportedMessageLink`

## GROUPCALLPARTICIPANTVIDEO (1 个方法)

- `groupCallParticipantVideo_groupCallParticipantVideo`

## JSONOBJECTVALUE (1 个方法)

- `jsonObjectValue_jsonObjectValue`

## SHIPPINGOPTION (1 个方法)

- `shippingOption_shippingOption`

## FOLDERPEER (1 个方法)

- `folderPeer_folderPeer`

## PEERBLOCKED (1 个方法)

- `peerBlocked_peerBlocked`

## MASKCOORDS (1 个方法)

- `maskCoords_maskCoords`

## HIGHSCORE (1 个方法)

- `highScore_highScore`

## STICKERKEYWORD (1 个方法)

- `stickerKeyword_stickerKeyword`

## CHANNELADMINLOGEVENTSFILTER (1 个方法)

- `channelAdminLogEventsFilter_channelAdminLogEventsFilter`

## DIALOGFILTERSUGGESTED (1 个方法)

- `dialogFilterSuggested_dialogFilterSuggested`

## INLINEBOTSWITCHPM (1 个方法)

- `inlineBotSwitchPM_inlineBotSwitchPM`

## RECEIVEDNOTIFYMESSAGE (1 个方法)

- `receivedNotifyMessage_receivedNotifyMessage`

## CHATADMINWITHINVITES (1 个方法)

- `chatAdminWithInvites_chatAdminWithInvites`

## CONTACT (1 个方法)

- `contact_contact`

## GROUPCALLPARTICIPANTVIDEOSOURCEGROUP (1 个方法)

- `groupCallParticipantVideoSourceGroup_groupCallParticipantVideoSourceGroup`

## SECUREDATA (1 个方法)

- `secureData_secureData`

## CONFIG (1 个方法)

- `config_config`

## MESSAGERANGE (1 个方法)

- `messageRange_messageRange`

## INPUTFOLDERPEER (1 个方法)

- `inputFolderPeer_inputFolderPeer`

## INPUTBOTINLINEMESSAGEID (1 个方法)

- `inputBotInlineMessageID_inputBotInlineMessageID`

## SECURESECRETSETTINGS (1 个方法)

- `secureSecretSettings_secureSecretSettings`

## EMOJILANGUAGE (1 个方法)

- `emojiLanguage_emojiLanguage`

## SPONSOREDMESSAGE (1 个方法)

- `sponsoredMessage_sponsoredMessage`

## SPONSOREDMESSAGEREPORTOPTION (1 个方法)

- `sponsoredMessageReportOption_sponsoredMessageReportOption`

## BANKCARDOPENURL (1 个方法)

- `bankCardOpenUrl_bankCardOpenUrl`

## SEARCHRESULTPOSITION (1 个方法)

- `searchResultPosition_searchResultPosition`

## SEARCHRESULTSCALENDARPERIOD (1 个方法)

- `searchResultsCalendarPeriod_searchResultsCalendarPeriod`

## INPUTSINGLEMEDIA (1 个方法)

- `inputSingleMedia_inputSingleMedia`

## INPUTPHONECALL (1 个方法)

- `inputPhoneCall_inputPhoneCall`

## PENDINGSUGGESTION (1 个方法)

- `pendingSuggestion_pendingSuggestion`

## GAME (1 个方法)

- `game_game`

## AVAILABLEREACTION (1 个方法)

- `availableReaction_availableReaction`

## WEBAUTHORIZATION (1 个方法)

- `webAuthorization_webAuthorization`

## POSTADDRESS (1 个方法)

- `postAddress_postAddress`

## AUTODOWNLOADSETTINGS (1 个方法)

- `autoDownloadSettings_autoDownloadSettings`

## CHANNELADMINRIGHTS (1 个方法)

- `channelAdminRights_layer92`

## SECURECREDENTIALSENCRYPTED (1 个方法)

- `secureCredentialsEncrypted_secureCredentialsEncrypted`

## GROUPCALLMESSAGE (1 个方法)

- `groupCallMessage_groupCallMessage`

## TEXTWITHENTITIES (1 个方法)

- `textWithEntities_textWithEntities`

## PAYMENTSAVEDCREDENTIALSCARD (1 个方法)

- `paymentSavedCredentialsCard_paymentSavedCredentialsCard`

## STICKERPACK (1 个方法)

- `stickerPack_stickerPack`

## INPUTENCRYPTEDCHAT (1 个方法)

- `inputEncryptedChat_inputEncryptedChat`

## NEARESTDC (1 个方法)

- `nearestDc_nearestDc`

## IMPORTEDCONTACT (1 个方法)

- `importedContact_importedContact`

## CHATONLINES (1 个方法)

- `chatOnlines_chatOnlines`

## PAGERELATEDARTICLE (1 个方法)

- `pageRelatedArticle_pageRelatedArticle`

## ACCOUNTDAYSTTL (1 个方法)

- `accountDaysTTL_accountDaysTTL`

## DCOPTION (1 个方法)

- `dcOption_dcOption`

## PAGETABLEROW (1 个方法)

- `pageTableRow_pageTableRow`

## EMOJIURL (1 个方法)

- `emojiURL_emojiURL`

## DECRYPTEDMESSAGELAYER (1 个方法)

- `decryptedMessageLayer_decryptedMessageLayer`

## FILEHASH (1 个方法)

- `fileHash_fileHash`

## TOPPEER (1 个方法)

- `topPeer_topPeer`

## PAYMENTREQUESTEDINFO (1 个方法)

- `paymentRequestedInfo_paymentRequestedInfo`

## MESSAGEREPORTOPTION (1 个方法)

- `messageReportOption_messageReportOption`

## INPUTTHEMESETTINGS (1 个方法)

- `inputThemeSettings_inputThemeSettings`

## SENDASPEER (1 个方法)

- `sendAsPeer_sendAsPeer`

## WEBVIEWRESULTURL (1 个方法)

- `webViewResultUrl_webViewResultUrl`

## ATTACHMENUBOTSBOT (1 个方法)

- `attachMenuBotsBot_attachMenuBotsBot`

## SIMPLEWEBVIEWRESULTURL (1 个方法)

- `simpleWebViewResultUrl_simpleWebViewResultUrl`

## WEBVIEWMESSAGESENT (1 个方法)

- `webViewMessageSent_webViewMessageSent`

## ATTACHMENUBOTICONCOLOR (1 个方法)

- `attachMenuBotIconColor_attachMenuBotIconColor`

## ATTACHMENUBOTICON (1 个方法)

- `attachMenuBotIcon_attachMenuBotIcon`

## APPWEBVIEWRESULTURL (1 个方法)

- `appWebViewResultUrl_appWebViewResultUrl`

## INLINEBOTWEBVIEW (1 个方法)

- `inlineBotWebView_inlineBotWebView`

## USERNAME (1 个方法)

- `username_username`

## DEFAULTHISTORYTTL (1 个方法)

- `defaultHistoryTTL_defaultHistoryTTL`

## EDITCLOSEFRIENDS (1 个方法)

- `editCloseFriends_editCloseFriends`

## PREMIUMGIFTCODEOPTION (1 个方法)

- `premiumGiftCodeOption_premiumGiftCodeOption`

## BUSINESSLOCATION (1 个方法)

- `businessLocation_businessLocation`

## TIMEZONE (1 个方法)

- `timezone_timezone`

## QUICKREPLY (1 个方法)

- `quickReply_quickReply`

## MISSINGINVITEE (1 个方法)

- `missingInvitee_missingInvitee`

## DATAJSON (1 个方法)

- `dataJSON_dataJSON`

## AVAILABLEEFFECT (1 个方法)

- `availableEffect_availableEffect`

## FACTCHECK (1 个方法)

- `factCheck_factCheck`

## EDITFACTCHECK (1 个方法)

- `editFactCheck_editFactCheck`

## DELETEFACTCHECK (1 个方法)

- `deleteFactCheck_deleteFactCheck`

## GETFACTCHECK (1 个方法)

- `getFactCheck_getFactCheck`

## STARSREVENUESTATUS (1 个方法)

- `starsRevenueStatus_starsRevenueStatus`

## PAYMENTCHARGE (1 个方法)

- `paymentCharge_paymentCharge`

## REPORTMESSAGESDELIVERY (1 个方法)

- `reportMessagesDelivery_reportMessagesDelivery`

## SPONSOREDPEER (1 个方法)

- `sponsoredPeer_sponsoredPeer`

## GETSAVEDMUSIC (1 个方法)

- `getSavedMusic_getSavedMusic`

## CHECKPAIDAUTH (1 个方法)

- `checkPaidAuth_checkPaidAuth`

## UPDATECONTACTNOTE (1 个方法)

- `updateContactNote_updateContactNote`

