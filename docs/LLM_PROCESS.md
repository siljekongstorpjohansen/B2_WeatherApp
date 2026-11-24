# LLM_PROCESS.md — B2 Weather App

> Appendix D. Written by Loke and Silje — not by the AI (`SPEC.md` §1). One entry per session.

## 1. Introduction
This document is made de describe how LLM models have been used in the work with this assignemen. The main LLm agent have been Claud. 

## 2. Overview of AI Usage

AI has been used as the prime generator of code for this project. After creating a SPEC file with clear instructions for how the AI should be used for the project. The creation of the code was done step by step where the AI gave the code and it was revievd and tested by the team members. 

---

## 3. Detailed Documentation of AI Usage
Here is a list of exampled promts and how they have been used to create the weather app. 

### 3.1 Documentation files 
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
- The AI takes in all teh information and often creates big complex documents. To make teh documents clearer and more readable the prompts/instructions to the LLM needs to be clear and it needs information telling it to make it short and readable. 
---

### 2026-11-20 — Xcode project setup (Loke)

- **Task given to the AI:** Guide me step by step through creating the Xcode project.
- **What it produced:**
  - `.gitignore`
  - Terminal checks after each step
  - Moved files to remove the extra folder level
  - Renaming
  - `.gitkeep` files so the empty folders could be pushed to GitHub
  - Commit and push
  - Update-log row
  - Added the `docs/` folder
- **What I kept / changed:**
  - I did all the Xcode set-up myself and set iOS 17.0 and `EXCLUDED_SOURCE_FILE_NAMES`.
  - I chose to remove the nesting and to name the struct `WeatherApp`, despite the module-name clash.
  - I kept `build/` in `.gitignore`.
- **Observations:**
  - It didn't know the new `project.pbxproj` format, so it inspected it before continuing.
  - It flagged the `.gitkeep` risk, and the build check confirmed it was real.
  - Checking the resolved settings caught two typos (`.gitkkep`, `gitkeep`).

### 3.2 Create the UI

**Date:** [23.november 2026]

**AI Tool:** [Claude]

**Purpose:**
The purpose was to start creating the UI so it can be testes and also make it possible to later conect the different parts of the project. AI created a suggestuin for a interface and implemented it with code. The app only displays fake data at this point. 

**Example of Prompts:**
- Create a suggestion for the home screen user interface
- Implement the suggestion
- Make a Interface for the settings screen according to the instructions
- Now create the favorites interface. Make it possible to sort the list after which favorit you check the most or in alphabetical order or after date added as favorite

**What needed to be changed?**
- ...

**Observations**
- ...
---
### 3.3 Update the UI

**Date:** [24.november 2026]

**AI Tool:** [Claude]

**Purpose:**
The purpose of todays session was to keep working on the UI to make the app work in the best way and to follow the requirements for the assignement. 

**Example of Prompts:**
- Start by: creating a detal view for the wether app it should show a full forecast for a selected day, including temperature, weather condition, and any additional data your chosen API provides.
- We go back to the favorites screen now, when i tap one of the favorites on my screen a quick view of the weather forcast fropm this place shows up. Implement that in the code
- Now go trough the whole UI code and clean it up, refactory. Make the code readable with suitable variable names but keep the same useability. Remove any unnecessary code

**What needed to be changed?**
- I made some updates to the favorites view to get a better user experience and to follow the instructions for the assignements. 

**Observations**
- ...
---

## 4. Summary

