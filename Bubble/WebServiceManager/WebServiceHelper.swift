//
//  WebServiceHelper.swift
//  Somi
//
//  Created by Paras on 24/03/21.
//

import Foundation
import UIKit



let BASE_URL = "https://ambitious.in.net/Shubham/bubble/index.php/api/"//Local
//let BASE_URL = "https://socialgamepro.com/admin/index.php/api/"//Live


struct WsUrl{
    
    static let url_SignUp  = BASE_URL + "signup?"
    static let url_getUserProfile  = BASE_URL + "get_profile"
    static let url_Login  = BASE_URL + "login"
    static let url_getPost = BASE_URL + "get_post"
    static let url_ForgotPassword = BASE_URL + "forgot_password"
    static let url_GetComments = BASE_URL + "get_comment"
    static let url_add_comment = BASE_URL + "add_comment"
    static let url_add_vote = BASE_URL + "add_vote"
    static let url_AddPost = BASE_URL + "add_post"
    static let url_GetNotofication = BASE_URL + "get_notifications"
    static let url_GetFavorite = BASE_URL + "get_favorite"
    static let url_DeletePost = BASE_URL + "delete_post"
    static let url_AddFavorite = BASE_URL + "add_favorite"
    static let url_GetRatings = BASE_URL + "get_ratings"
    static let url_UpdateProfile = BASE_URL + "update_profile"
    
    
    
    static let url_ChangePassword = BASE_URL + "change_password"
    static let url_ContactUs = BASE_URL + "contact_us"
    
   

    static let url_DeleteNotification = BASE_URL + "delete_notification"

    static let url_InsertChat = BASE_URL + "insert_chat"
    static let url_GetChat = BASE_URL + "get_chat"
 
    static let url_ReportUser = BASE_URL + "report_user"
    static let url_BlockUser = BASE_URL + "block_user?"
    static let url_DeleteAccunt = BASE_URL + "delete_user?user_id="
    static let url_deleteChatSingleMessage = BASE_URL + "delete_a_message?"
    static let url_clearConversation = BASE_URL + "clear_conversation"
    static let url_insertChat = BASE_URL + "insert_chat"
    static let url_getChatList = BASE_URL + "get_chat"
}


//Api Header

struct WsHeader {

    //Login

    static let deviceId = "Device-Id"

    static let deviceType = "Device-Type"

    static let deviceTimeZone = "Device-Timezone"

    static let ContentType = "Content-Type"

}



//Api parameters

struct WsParam {

    

    //static let itunesSharedSecret : String = "c736cf14764344a5913c8c1"

    //Signup

    static let dialCode = "dialCode"

    static let contactNumber = "contactNumber"

    static let code = "code"

    static let deviceToken = "deviceToken"

    static let deviceType = "deviceType"

    static let firstName = "firstName"

    static let lastName = "lastName"

    static let email = "email"

    static let driverImage = "driverImage"

    static let isSignup = "isSignup"

    static let licenceImage = "licenceImage"

    static let socialId = "socialId"

    static let socialType = "socialType"

    static let imageUrl = "image_url"

    static let invitationId = "invitationId"

    static let status = "status"

    static let companyId = "companyId"

    static let vehicleId = "vehicleId"

    static let type = "type"

    static let bookingId = "bookingId"

    static let location = "location"

    static let latitude = "latitude"

    static let longitude = "longitude"

    static let currentdate_time = "current_date_time"

}



//Api check for params
struct WsParamsType {
    static let PathVariable = "Path Variable"
    static let QueryParams = "Query Params"
}

/*
 public interface LoadInterface {
 
 @POST("signup")
 Call<ResponseBody> signup(@Query("name") String name,
 @Query("email") String email,
 @Query("mobile") String mobile,
 @Query("dob") String dob,
 @Query("password") String password,
 @Query("gender") String gender,
 @Query("register_id") String register_id);
 
 @POST("anonymous_login")
 Call<ResponseBody> anonymous_login(@Query("device_type") String device_type,
 @Query("device_id") String device_id,
 @Query("register_id") String register_id);
 
 @POST("social_login")
 Call<ResponseBody> social_login(@Query("social_type") String social_type,
 @Query("social_id") String social_id,
 @Query("name") String name,
 @Query("email") String email,
 @Query("register_id") String register_id);
 
 @POST("login")
 Call<ResponseBody> login(@Query("username") String username,
 @Query("password") String password,
 @Query("register_id") String register_id);
 
 @POST("forgot_password")
 Call<ResponseBody> forgot_password(@Query("email") String email);
 
 @POST("get_category")
 Call<ResponseBody> get_category();
 
 @POST("add_game")
 Call<ResponseBody> add_game(@Query("user_id") String user_id,
 @Query("category_id") String category_id,
 @Query("time") String time,
 @Query("date") String date,
 @Query("location") String location,
 @Query("lat") String lat,
 @Query("lng") String lng,
 @Query("number_of_players") String number_of_players);
 
 @POST("get_game")
 Call<ResponseBody> get_game(@Query("user_id") String user_id,
 @Query("login_id") String login_id,
 @Query("category_id") String category_id);
 
 @POST("get_game")
 Call<ResponseBody> get_joined_game(@Query("player_id") String user_id);
 
 @POST("request_to_join_game")
 Call<ResponseBody> request_to_join_game(@Query("user_id") String user_id,
 @Query("game_id") String game_id);
 
 @POST("update_profile")
 Call<ResponseBody> update_profile(@Query("user_id") String user_id,
 @Query("name") String name,
 @Query("email") String email,
 @Query("mobile") String mobile,
 @Query("dob") String dob);
 
 @Multipart
 @POST("update_profile")
 Call<ResponseBody> update_profileimg(@Query("user_id") String user_id,
 @Query("name") String name,
 @Query("email") String email,
 @Query("mobile") String mobile,
 @Query("dob") String dob,
 @Part MultipartBody.Part body1);
 
 @POST("change_password")
 Call<ResponseBody> change_password(@Query("user_id") String user_id,
 @Query("old_password") String old_password,
 @Query("new_password") String new_password);
 
 @Multipart
 @POST("contact_us")
 Call<ResponseBody> contact_us(@Query("user_id") String user_id,
 @Query("subject") String subject,
 @Query("message") String message,
 @Part MultipartBody.Part body1);
 
 @POST("get_game_players")
 Call<ResponseBody> get_game_requests(@Query("game_id") String game_id,
 @Query("approved") String approved);
 
 @POST("accept_request")
 Call<ResponseBody> accept_request(@Query("game_id") String game_id,
 @Query("user_id") String user_id);
 
 @POST("get_profile")
 Call<ResponseBody> get_profile(@Query("user_id") String user_id,
 @Query("login_id") String login_id);
 
 @POST("follow_user")
 Call<ResponseBody> follow_user(@Query("user_id") String user_id,
 @Query("follower_id") String follower_id);
 
 @POST("get_conversation")
 Call<ResponseBody> get_conversation(@Query("user_id") String user_id);
 
 @POST("insert_chat")
 Call<ResponseBody> insertChat(@Query("sender_id") String sender_id,
 @Query("receiver_id") String receiver_id,
 @Query("product_id") String product_id,
 @Query("chat_message") String chat_message);
 
 @POST("get_chat")
 Call<ResponseBody> getChat(@Query("sender_id") String sender_id,
 @Query("receiver_id") String receiver_id,
 @Query("product_id") String product_id);
 
 
 @POST("get_notification")
 Call<ResponseBody> get_notification(@Query("user_id") String user_id);
 
 @POST("delete_notification")
 Call<ResponseBody> delete_notification(@Query("user_id") String user_id,
 @Query("notification_id") String notification_id);
 
 @Multipart
 @POST("signup")
 Call<ResponseBody> signup1(@Query("type") String type,
 @Query("email") String email,
 @Query("name") String name,
 @Query("mobile") String mobile,
 @Query("nationality") String nationality,
 @Query("address") String address,
 @Query("password") String password,
 @Query("register_id") String register_id,
 @Part MultipartBody.Part body1);
 
 
 @POST("get_appointment")
 Call<ResponseBody> get_my_appointment(@Query("babysitter_id") String user_id,
 @Query("status") String status);
 
 @POST("update_appointment")
 Call<ResponseBody> update_appointment(@Query("appointment_id") String specialist_id,
 @Query("status") String status);
 
 @POST("get_review")
 Call<ResponseBody> get_review(@Query("babysitter_id") String babysitter_id);
 
 @POST("rating")
 Call<ResponseBody> rating(@Query("user_id") String user_id,
 @Query("babysitter_id") String babysitter_id,
 @Query("appointment_id") String appointment_id,
 @Query("rating") String rating,
 @Query("review") String review);
 
 @POST("get_nationality")
 Call<ResponseBody> get_nationality();
 
 @POST("get_state")
 Call<ResponseBody> get_state(@Query("country_id") String country_id);
 
 @POST("get_city")
 Call<ResponseBody> get_city(@Query("state_id") String state_id);
 
 
 @POST("contact_us")
 Call<ResponseBody> contact_us(@Query("user_id") String user_id,
 @Query("subject") String title,
 @Query("message") String message);
 
 
 @POST("get_customer_pages")
 Call<ResponseBody> get_customer_pages();
 
 }
 */
