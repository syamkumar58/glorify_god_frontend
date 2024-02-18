const bool useLocalHost = false;

const String localHost = 'localhost'; //'10.0.2.2'; //
// < If platform is Android use '10.0.2.2' as host and IOS uses 'localhost'>/
const String hostUrl =
    useLocalHost ? 'http://$localHost:8000' : 'https://api.glorifygod.in';

const String loginUrl = '$hostUrl/login/user_login_call';
const String getUserByIDUrl = '$hostUrl/login/get_user_by_id';
const String createArtistUrl = '$hostUrl/artist/createArtist';
const String getArtistWithSongsUrl = '$hostUrl/getArtists/getArtistsWithSongs';
const String addFavouritesUrl = '$hostUrl/favourites/addFavourites';
const String unFavouritesUrl = '$hostUrl/favourites/unFavourite';
const String getFavouritesUrl = '$hostUrl/favourites/getFavourites';
const String checkFavUrl = '$hostUrl/favourites/checkSongIdAddedOrNot';
const String searchUrl = '$hostUrl/search';
const String getAllSongs = '$hostUrl/songs/getAllSongs';
const String updateRatingUrl = '$hostUrl/rateApp/rateTheApp';
const String getRatingUrl = '$hostUrl/rateApp/getUserRating';
const String feedbackUrl = '$hostUrl/feedBack/feedback';
const String getUserReportedIssuesByIdUrl =
    '$hostUrl/feedBack/getUserReportedIssuesById';
const String privacyPolicyUrl = '$hostUrl/privacyPolicy';
const String privacyPolicyAcceptedUrl =
    '$hostUrl/privacyPolicy/checkUserAcceptedPolicyById';
const String removeUserFromPrivacyPolicyUrl = '$hostUrl/privacyPolicy/removePrivacyPolicy';
const String updateTrackerDetailsUrl = '$hostUrl/tracker/updateTracker';
const String getTrackerDetailsByIdUrl = '$hostUrl/tracker/trackerDetailsById';
const String addArtistsSongDataByIdUrl = '$hostUrl/artistsSongData/addArtistsSongData';
const String getArtistsSongDataByIdUrl = '$hostUrl/artistsSongData/artistsSongDataById';
const String checkArtistLoginDataByIdUrl = '$hostUrl/artistsSongData/checkArtistEmail';

