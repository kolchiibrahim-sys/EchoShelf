//
//  OnboardingViewModel.swift
//  EchoShelf
//
//  Created by Ibrahim Kolchi on 14.03.26.
//
import Foundation

final class OnboardingViewModel {

    private(set) var pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "OnboardingLibrary",
            badge: "NEW ARRIVALS",
            title: "Welcome to the Library",
            highlightedWord: "Library",
            subtitle: "Explore our vast collection of timeless classics and the latest modern bestsellers at your fingertips.",
            primaryButtonTitle: "Continue →",
            secondaryButtonTitle: nil
        ),
        OnboardingPage(
            imageName: "OnboardingNarrator",
            badge: "PREMIUM NARRATED",
            title: "Human Narrations",
            highlightedWord: nil,
            subtitle: "Experience stories brought to life by award-winning voice actors with studio-grade spatial audio.",
            primaryButtonTitle: "Continue to Listen →",
            secondaryButtonTitle: "Skip for now"
        ),
        OnboardingPage(
            imageName: "OnboardingKids",
            badge: nil,
            title: "A Safe Space for Young Readers",
            highlightedWord: "Young Readers",
            subtitle: "Carefully curated stories and adventures designed specifically for children.",
            primaryButtonTitle: "Continue to Adventure →",
            secondaryButtonTitle: "Maybe later"
        ),
        OnboardingPage(
            imageName: "OnboardingFamily",
            badge: nil,
            title: "Safe for the whole family",
            highlightedWord: nil,
            subtitle: "Create dedicated profiles for your kids with age-appropriate content and a secure safe-mode toggle.",
            primaryButtonTitle: "Finish Setup",
            secondaryButtonTitle: "I'll do this later"
        ),
        OnboardingPage(
            imageName: "OnboardingOffline",
            badge: "READY TO GO",
            title: "Your Library, Anywhere",
            highlightedWord: nil,
            subtitle: "No Wi-Fi? No problem. Browse your entire library for car rides, long flights, or remote adventures.",
            primaryButtonTitle: "Finish Setup 🚀",
            secondaryButtonTitle: "Learn more about downloads"
        ),
        OnboardingPage(
            imageName: "OnboardingReady",
            badge: nil,
            title: "Ready to dive in?",
            highlightedWord: nil,
            subtitle: "Your personal library of stories and knowledge awaits. Experience the future of reading.",
            primaryButtonTitle: "Get Started",
            secondaryButtonTitle: "Sign In"
        )
    ]

    var currentIndex: Int = 0

    var isLastPage: Bool {
        currentIndex == pages.count - 1
    }

    var currentPage: OnboardingPage {
        pages[currentIndex]
    }

    func goNext() {
        if currentIndex < pages.count - 1 {
            currentIndex += 1
        }
    }

    func goPrevious() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
}
