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
inline const QString kApiKey = QStringLiteral("1994d5bda908c696a7acf7ee0b49d0d7");

//*+*+*+*+*+ Bearer token for Authorization header (preferred auth method) **+*+*+*+*
inline const QString kReadAccessToken = QStringLiteral(
    "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxOTk0ZDViZGE5MDhjNjk2YTdhY2Y3ZWUwYjQ5ZDBkNyIsIm5iZiI6MTc3OTQyMDk3Ni4yOTYsInN1YiI6IjZhMGZjZjMwYWZiZWU0MmE3NmRlMWIzMyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.3QtGDD0FpjXd2Gjut7Bin0Oix51ClwFSJG9cDO6OyF");

// ── Base URL ─────────────────────────────────────────────────────
inline const QString kBaseUrl = QStringLiteral("https://api.themoviedb.org/3");

// ── Endpoint paths ──────────────────────────────────────────────
//*+*+*+*+*+ Search endpoint — finds movies by title, optionally filtered by year **+*+*+*+*
inline const QString kSearchMoviePath = QStringLiteral("/search/movie");

}