#pragma once

#include <QString>

// All Internet Archive (archive.org) API details in one place.
// If archive.org ever changes its endpoints, or we swap providers,
// this is the only file that needs to change.
namespace ArchiveConstants {

// ── Base URL ─────────────────────────────────────────────────────
inline const QString kBaseUrl = QStringLiteral("https://archive.org");

// ── Endpoint paths (use with .arg() where %1/%2 placeholders exist) ─
inline const QString kAdvancedSearchPath = QStringLiteral("/advancedsearch.php");
inline const QString kMetadataPath       = QStringLiteral("/metadata/%1");
inline const QString kDownloadPath       = QStringLiteral("/download/%1/%2");
inline const QString kPosterImagePath    = QStringLiteral("/services/img/%1");

// ── Search query building blocks ────────────────────────────────
inline const QString kCuratedQueryFilter =
    QStringLiteral("collection:feature_films AND mediatype:movies AND -subject:\"adult\"");

inline const QString kSearchQueryTemplate =
    QStringLiteral("(%1) AND mediatype:movies AND collection:feature_films");

// ── Result limits ────────────────────────────────────────────────
inline const int kCuratedResultRows = 30;
inline const int kSearchResultRows  = 20;
}

//*+*+*+*+*+ TMDB (The Movie Database) API constants for fetching real ratings & overviews **+*+*+*+*
namespace TmdbConstants {

// ── API credentials ─────────────────────────────────────────────
//*+*+*+*+*+ API key used as query param fallback **+*+*+*+*
inline const QString kApiKey = QStringLiteral("");//insert your TMDB API KEY HERE

//*+*+*+*+*+ Bearer token for Authorization header (preferred auth method) **+*+*+*+*
inline const QString kReadAccessToken = QStringLiteral(
    ""); //insert your TMDB API auth header in here

// ── Base URL ─────────────────────────────────────────────────────
inline const QString kBaseUrl = QStringLiteral("https://api.themoviedb.org/3");

// ── Endpoint paths ──────────────────────────────────────────────
//*+*+*+*+*+ Search endpoint — finds movies by title, optionally filtered by year **+*+*+*+*
inline const QString kSearchMoviePath = QStringLiteral("/search/movie");

}
