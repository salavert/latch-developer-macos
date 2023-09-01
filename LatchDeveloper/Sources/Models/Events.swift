import Foundation

enum Events {
    static let addOperation = "add_operation"
    static let getApplicationsList = "get_applications_list"
    static let updateConfig = "update_config"
    static let redirectingToOnboarding = "redirecting_to_onboarding"
    static let showingBugsSetting = "show_bugs_setting"
    static let showingConfigSetting = "show_config_setting"
    static let copyRequestToClipboard = "copy_request"
    static let copyResponseToClipboard = "copy_response"
    static let checkStatus = "check_status"
    static let checkStatusManual = "check_status_manual"
    static let deleteOperation = "delete_operation"
    static let modifyStatus = "modify_status"
    static let getSubscription = "get_subscription"
    static let unpair = "unpair"
    static let unpairManual = "unpair_manual"
    static let getUserHistory = "get_user_history"
    static let pairWithToken = "pair_with_token"
    static let pairWithId = "pair_with_id"
    static let clearAllData = "clear_all_data"
    static let responseInvalidStatusCode = "response_failure"
    static let responseInvalidErrorCode = "response_error"
    static let responseSuccess = "response_success"
    static let configuredNonProductionHost = "configured_non_production_host"
    static let showPreviousLog = "show_previous_log"
    static let switchToApplication = "switch_to_application"
}
