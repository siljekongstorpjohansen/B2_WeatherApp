# REFLECTION.md — B2 Weather App

> Reflection report (~½ page, W-40). Written by Loke and Silje — not by the AI (`SPEC.md` §1).

## 

## Final reflection
When working on this project, we wanted to learn from the positives and negatives of the N-back project. Creating a clear SPEC file as the first part of this project gave clear guidelines and a plan for both us and the AI to follow. The workflow was more structured, the prompts for the AI were easier to write, and the AI gave more accurate code on the first try. The AI also knew to add handlers for user interactions right away, so running and testing the code went smoothly.

To get more structured code, the AI was given instructions multiple times to clean up the code and "refactor" it. Insights gained from working on the N-back assignment show that the AI often gives long code with unnecessarily many functions and variables. Cleaning up the code makes it more readable and easier to follow and keep working on. This is even more important for this project, as we are two students working together and have to understand each other's work.

The part of the code we are most satisfied with is its structure. It is a result of structural work and clear prompts to the AI to keep the code structured and easy to read. This also made it easier to add new features and parts of the project step by step, and to make everything work together in the end.

What still surprises us, and the difficult part of the project, is keeping up with the AI. So much code gets produced in a short amount of time. The structure of the code is understandable from the explanations the AI gives after every update, but understanding the details is complicated. The teamwork also makes it harder, since we have to understand another person's code at the same time. The LLM easily scans through what the other group member has added since last time and can keep working, while we need time to understand the different parts. Using the AI to explain the different parts, and where in the code they are relevant, helps the understanding and is a good tool for learning about the code.

What we would do differently
We would focus less on understanding every generated file and more on the app's architecture. Without much earlier development experience, it was hard to know what to focus on. We think LLMs will become more useful as we gain experience, because a solid base of coding knowledge makes it much faster to verify what the AI produces.

As of today, we cannot explain every class in detail, such as what the specific syntax does, but we can explain individual functions and how they fit into the app. One example is ForecastViewModel.load together with run; another is GeocodingParser.place(from:).
