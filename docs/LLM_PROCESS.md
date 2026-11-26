# LLM_PROCESS.md — B2 Weather App

> Appendix D. Written by Loke and Silje — not by the AI (`SPEC.md` §1). One entry per session.

## 1. Introduction
This document is made de describe how LLM models have been used in the work with this assignemen. The main LLm agent have been Claud. 

## 2. Overview of AI Usage

AI has been used as the prime generator of code for this project. After creating a SPEC file with clear instructions for how the AI should be used for the project. The creation of the code was done step by step where the AI gave the code and it was revievd and tested by the team members. 

---

## 3. Detailed Documentation of AI Usage
Here is a list of exampled promts and how they have been used to create the weather app. 

### Documentation files (Silje)
**Date:** [13-16. November 2026]

**AI Tool:** [Claude]

**Purpose:**
The work started with creatng teh SPEC.md, STYLE.md and CONTEXT.md. The first draft of the files were created by the LLM model based on the assignement instructions. I later filled in the information needed and asked to have the file shorter and more clear. The files were created one by one so I could review them and make changes before starting the next file. 

**Example of Prompt**
- Start by creating a SPEC.md file for the project according to the project instructions." The Lab-B2-Weather.pdf was attached.
- Can you make the spec file shorter and more compact? Make it easier to read
- I have made a few changes in the SPEC file, check them and now create the STYLE.md file

**What needed to be changed?** 
- The AI missed the course code, Two courses uses the same assignement so I made sure it was changed to the correct one in teh SPEC.md file.
- The first drafts of the files were very long and hard to read and understand, after cxreating better prompts the files were better and easier to read.

**Observations**
- The AI takes in all teh information and often creates big complex documents. To make the documents clearer and more readable the prompts/instructions to the LLM needs to be clear and it needs information telling it to make it short and readable. 
---
### Promt that worked well (used in all sessions (loke))

1. **Repo check (Claude chat)**

   > Summarise this WeatherApp repo state in under 150 words:
   > - Current branch, and whether develop and main are in sync.
   > - Uncommitted changes or untracked files.
   > - Open PRs and their target branches.
   > - Anything risky (wrong target, unpushed commits, conflicts).
   >
   > Don't suggest code changes yet.

2. **Draft the Claude Code prompt (Claude chat)**

   > Based on the repo summary above, draft a starting prompt for Claude Code. Include:
   > - A placeholder for today's goal, which I will fill in.
   > - Any setup the repo state requires before work can start.
   > - Standing rules for git, deletions, and test reporting.
   > - What to report back when done.
   >
   > Under 200 words.

3. **Edit and run (Claude Code)**

   I edit the draft to match what I want to work on today, then paste it into Claude Code.

---
### 2026-11-20 — Xcode project setup (Loke)

- **Task given to the AI:** I asked the AI to guide me step by step through creating the Xcode project and getting it up on GitHub.
- **What it produced:** It walked me through the setup and checked in the terminal after each step that everything looked right. It created a file that tells git which files to ignore, moved the files to get rid of an extra folder level and renamed things so they matched. It added small placeholder files so the empty folders could be pushed to GitHub, added a folder for our documents, wrote a row in the update log, and helped me commit and push everything.
- **What I kept / changed:** I did all the setup in Xcode myself, including setting the minimum iOS version to 17.0 and a setting that keeps the placeholder files out of the app build. I also chose to keep the build folder in the ignore file.
- **Observations:**
  - The AI didn't know the newer format of Xcode's project file, so it looked at the file first before going on, instead of guessing.
  - Checking the project settings afterwards caught two typos in the file names, so the extra checks were worth it.

---
### Create the UI (Silje)

**Date:** [23.november 2026]

**AI Tool:** [Claude]

**Purpose:**
The purpose was to start creating the UI so it can be testes and also make it possible to later conect the different parts of the project. AI created a suggestion for a interface and implemented it with code. The app only displays fake data at this point. 

**Example of Prompts:**
- Create a suggestion for the home screen user interface
- Implement the suggestion
- Make a Interface for the settings screen according to the instructions
- Now create the favorites interface. Make it possible to sort the list after which favorit you check the most or in alphabetical order or after date added as favorite

**What needed to be changed?**
- In this session the AI followed the instructions clearly so not much needed to be changed

**Observations**
- When getting clear instructions the AI creates usable code fast, where the instructions lacks clearity it ask questions back makling my reflect about where my prompts lack clearity 
---
### 2026-11-23 — Skeleton through all layers (Loke)

- **Task given to the AI:** I asked the AI to build a first skeleton of the app. The goal was to get a real weather forecast for Stockholm all the way from the weather API into the app logic, without building any screens yet.
- **What it produced:** It wrote the data models, the code that reads the API response, the network code, a real and a fake data source, and the logic that prepares the forecast for the screens. It also wrote 14 unit tests and one test against the live API that only runs when you ask for it. When I merged Silje's UI branch, it walked me through the merge and solved the conflicts by keeping both of our changes.
- **What I kept / changed:** I kept the decisions I had made in my prompts, for example how errors should be handled, that a time zone should be added, that old searches should be cancelled when a new one starts, and that the normal tests should use saved test data instead of the live API.
- **Observations:**
  - I didn't notice any mistakes from the AI in this session.

---
### Update the UI and create functional screens (Silje)

**Date:** [24.november 2026]

**AI Tool:** [Claude]

**Purpose:**
The purpose of todays session was to keep working on the UI to make the app work in the best way and to follow the requirements for the assignement. Also to update the UI to work in a functional way. 

**Example of Prompts:**
- Start by: creating a detal view for the wether app it should show a full forecast for a selected day, including temperature, weather condition, and any additional data your chosen API provides.
- We go back to the favorites screen now, when i tap one of the favorites on my screen a quick view of the weather forcast fropm this place shows up. Implement that in the code
- Now go trough the whole UI code and clean it up, refactory. Make the code readable with suitable variable names but keep the same useability. Remove any unnecessary code
- Go over to the favorites and settings page and make them actually work. Add functions to the buttons
- In the home screen, add if the degrees are dispayed in celsius or farenheit in a nice way. Also add storage of the latest forecast so it can be displayed if the phone is offline when opening the phone, do this accoridning to the SPEC instructions

**What needed to be changed?**
- I made some updates to the favorites view to get a better user experience and to follow the instructions for the assignements.
- After testimg the settings on my phone I made som changes to the interface so it was more clear how the app worked for the user. 

**Observations**
- When looking only at the feedback from the AI it looks like everything will work perfectly, but after testing the functions myself the lack of userfriendliness is more clear. To get the app more user friendly I try to promt in a more clear way with simple instructions for the model to follow. 
---
### 2026-11-24 — Branch clean-up, live data and geocoding (Loke)

- **Task given to the AI:** First I asked it to clean up our branches on GitHub and combine Silje's and my AI logs into one file. I gave it clear rules: explain every git command, ask before deleting anything and never merge into main. After that I asked it to connect the start screen to real weather data, add a real city search with my API key, and write a setup guide.
- **What it produced:** It cleaned up the branches, deleted the old ones after asking me, and copied Silje's log into ours exactly as she wrote it. It explained how the city search and the weather API work together in a simple way, Then it connected the start screen to live data, added a retry button with a test, and built the city search with tests. It was careful with my API key and never showed it or put it in a commit. It also wrote the setup guide and made the release to main.
- **What I kept / changed:** I picked how the start screen should be connected from the options. For the city search I decided which name to show, that bad results should just be skipped and how errors should be handled. I approved all the tests and checked one myself by removing a check in the code and seeing that the test failed.
- **Observations:**
  - It made a few small mistakes. A command it used to check the work didn't work and had to be redone, and it explained some git commands after running them instead of before.
  - Its Xcode instructions didn't match what I saw on my screen, so we had to solve it another way.

---
### 2026-11-25 — Connectivity, tests and hand-in docs (Loke)

- **Task given to the AI:** Silje's latest changes had ended up in main instead of develop, so I asked the AI to fix the branches. After that I asked it to check the layout in portrait and landscape, write the remaining tests and code,  clean up and check our spec document and markdown documents, push my last changes and make the final release.
- **What it produced:** It fixed the branches and found out why the problem happened: GitHub sends new pull requests to main by default. It tested Silje's code, summarised her changes and suggested what order to do the rest of the work in. For the layout check it took 20 screenshots (i provided) and found 6 small layout issues. It added a check for when the phone goes offline and online, wrote mutation tests to see if our tests actually catch bugs, wrote new tests where they didn't, and added an architecture description to the README. It also found 7 places where the spec didn't match the code and fixed them. Before pushing, it ran all the tests and found that one of my tests sometimes failed, and fixed it after asking me.
- **What I kept / changed:** I chose to do do the rotation test by hand and provide the screenshots instead of letting it write a new test for it. I changed the rule so it could only tick results it had actually seen from a real run, and I did the other 25 tests myself. For the empty rows in the spec I mostly picked the options it recommended, but chose differently on one of them.
- **Observations:**
  - The AI pushed back when it was needed. It told me my request went against our own rules for writing code, and it refused to write test results without prof the were performed because the course doesn't allow that.
  - The mutation tests showed that one of the AI's own tests didn't test what its name said, so it had to be rewritten. This was a good way to check the AI's code.
  - The release got messy. It started the release before seeing that Silje had pushed straight to main, which caused a conflict. It also switched my branch without telling me, so I thought my changes were gone. In the end we needed an extra pull request to get the test results into main.

---

### Understanding the code and documentation 

**Date:** [25.november 2026]

**AI Tool:** [Claude]

**Purpose:**
This session was mostly a final check that everything in the code is working as it should and starting to get a better understanding of the code

**Example of Prompts:**
- Help explain how the code stores the data when closing the appp

**What needed to be changed?**
- Some of the anwsers given by the AI was long and hard to read and missed refences to the code. Often I asked for clearifications and where in the code the action is handled.

**Observations**
- Using the AI to understand the code can give good anwsers when the prompt is good. Sometimes alot of information is given that not necesseraly helps me get a better understanding.
- Getting more explanation from the AI when working with the code made it easier to revise in the end of the project.
