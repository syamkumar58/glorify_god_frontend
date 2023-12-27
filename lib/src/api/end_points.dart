const String localHost = '10.0.2.2'; //'localhost'; //
// < If platform is Android use '10.0.2.2' as host and IOS uses 'localhost'>/
const String loginUrl = 'http://$localHost:8000/login/user_login_call';
const String getUserByIDUrl = 'http://$localHost:8000/login/get_user_by_id';
const String createArtistUrl = 'http://$localHost:8000/artist/createArtist';
const String getArtistWithSongsUrl =
    'http://$localHost:8000/getArtists/getArtistsWithSongs';
const String addFavouritesUrl =
    'http://$localHost:8000/favourites/addFavourites';
const String unFavouritesUrl = 'http://$localHost:8000/favourites/unFavourite';
const String getFavouritesUrl =
    'http://$localHost:8000/favourites/getFavourites';
const String checkFavUrl =
    'http://$localHost:8000/favourites/checkSongIdAddedOrNot';
const String searchUrl = 'http://$localHost:8000/search';
const String getAllSongs = 'http://$localHost:8000/songs/getAllSongs';
const String updateRatingUrl = 'http://$localHost:8000/rateApp/rateTheApp';
const String getRatingUrl = 'http://$localHost:8000/rateApp/getUserRating';
const String feedbackUrl = 'http://$localHost:8000/feedBack/feedback';
const String getUserReportedIssuesByIdUrl =
    'http://$localHost:8000/feedBack/getUserReportedIssuesById';
