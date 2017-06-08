# PROJECT BASED ASSESSMENT: Build a CLI Application with External Data

## Overview

This package is intended to fulfill the requirements of the Flatiron School
lesson entitled "CLI Data Gem Project".

It performs the following backend functions:
(1) makes calls to the Librivox API to get a very limited amount of data on
    Librivox audiobooks, most importantly the URL to each audiobook's Librivox
    webpage;
(2) makes calls to each audiobook's webpage to scrape data, including title,
    author(s), reader(s), genre(s);
(3) loads all data into a cross-referenced hierarchy of objects

It also provides a CLI interface for browsing the resultant audiobook "catalog"
via several categories.

Note that, in order to provide for O(log n) efficiency in querying the various
categories, a new class, HashWithBsearch, was written. If time permits, it may
be worthwhile to publish an enhanced version of this class as a gem.

## Requirements

1. Provide a CLI
2. CLI must provide access to data from a web page.
3. The data provided must go at least one level deep, generally by showing the user a list of available data and then being able to drill down into a specific item.
4. The CLI application can not be a Music CLI application as that is too similiar to the other OO Ruby final project. Also please refrain from using Kickstarter as that was used for the scraping 'code along'. Look at the example domains below for inspiration.
5. Use good OO design patterns. You should be creating a collection of objects - not hashes.


*For bonus points, instead of just creating an application, create a gem and for extra bonus points try publishing it to RubyGems.*


## Instructions

1. Create a new repository on GitHub for your application, ie: `name-cli-app`.
2. When you create the CLI app for your assessment, add the spec.md file from this repo to the root directory of the project, commit it to Git and push it up to GitHub.
3. Build your application. Make sure to commit early and commit often. Commit messages should be meaningful (clearly describe what you're doing in the commit) and accurate (there should be nothing in the commit that doesn't match the description in the commit message). Good rule of thumb is to commit every 3-7 mins of actual coding time. Most of your commits should have under 15 lines of code and a 2 line commit is perfectly acceptable. **This is important and you'll be graded on this**.
4. Make sure to create a good README.md with a short description, install instructions, a contributors guide and a link to the license for your code.
5. While you're working on it, record a 30 min coding session with your favorite screen capture tool. During the session, either think out loud or not. It's up to you. You don't need to submit the video, but we may ask for it at a later time.
6. Make sure to check each box in your spec.md (replace the space between the square braces with an x) and explain next to each one how you've met the requirement *before* you submit your project.
7. Prepare a video demo (narration helps!) describing how a user would interact with your working gem.
8. Write a blog post about the project and process.
9. On Learn, submit links to the GitHub repository for your app, your video demo, and your blog post each to the corresponding textbox in the right rail, and hit "I'm done" to wrap it up.

## Resources

- [How to build a ruby gem](http://guides.rubygems.org/make-your-own-gem/)
- [How to publish your gem](http://guides.rubygems.org/publishing/)
- [Environments, Requiring Files, Bundler, and Gems](https://www.youtube.com/watch?v=XBgZLm-sdl8)
- [Video- CLI Data Gem Walkthrough](https://www.youtube.com/watch?v=_lDExWIhYKI)
- [Video- CLI Data Gem Walkthrough: Creating a CLI Scraper Gem](https://www.youtube.com/watch?v=Y5X6NRQi0bU)
- [Video- Common Anti-Patterns in CLI Data Gem](https://www.youtube.com/watch?v=cbMa87oWv08)
- [Video- Student Example 1: Refactoring CLI Data Gem](https://www.youtube.com/watch?v=JEL_PXr74qQ)
- [Video- Student Example 2: Refactoring CLI Data Gem](https://www.youtube.com/watch?v=Lt0oyHiKWIw)
