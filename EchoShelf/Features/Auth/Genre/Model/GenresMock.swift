//
//  GenresMock.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 22.03.26.
//
import Foundation

struct Genre: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let colorName: String
}

extension Genre {
    static let all: [Genre] = [
        Genre(id: "fantasy",     name: "Fantasy",     description: "Epic worlds, magic, and mythical creatures beyond imagination.",      icon: "🧙",  colorName: "TrendingAIPicks"),
        Genre(id: "drama",       name: "Drama",       description: "Powerful stories exploring human emotions and relationships.",          icon: "🎭",  colorName: "TrendingNarrators"),
        Genre(id: "romance",     name: "Romance",     description: "Heartfelt love stories that captivate and inspire.",                   icon: "💕",  colorName: "FavoriteActivePink"),
        Genre(id: "mystery",     name: "Mystery",     description: "Suspenseful tales of crime, detectives, and hidden secrets.",          icon: "🔍",  colorName: "TrendingThriller"),
        Genre(id: "sci-fi",      name: "Sci-Fi",      description: "Futuristic worlds, space exploration, and advanced technology.",       icon: "🚀",  colorName: "TrendingSciFi"),
        Genre(id: "history",     name: "History",     description: "True accounts of past civilizations and world-changing events.",       icon: "📜",  colorName: "TrendingClassics"),
        Genre(id: "adventure",   name: "Adventure",   description: "Thrilling journeys, daring quests, and brave heroes.",                icon: "🗺️",  colorName: "TrendingBestsellers"),
        Genre(id: "kids",        name: "Kids",        description: "Wonderful stories for young readers to learn and imagine.",            icon: "⭐",  colorName: "RatingStarYellow"),
        Genre(id: "horror",      name: "Horror",      description: "Spine-chilling tales that keep you up at night.",                     icon: "👻",  colorName: "IconDarkRed"),
        Genre(id: "biography",   name: "Biography",   description: "True life stories of remarkable people who shaped the world.",        icon: "👤",  colorName: "IconBlue"),
        Genre(id: "philosophy",  name: "Philosophy",  description: "Deep explorations of existence, ethics, and the human condition.",    icon: "💭",  colorName: "IconPurple"),
        Genre(id: "science",     name: "Science",     description: "Discoveries, experiments, and wonders of the natural world.",         icon: "🔬",  colorName: "IconGreen")
    ]
}
