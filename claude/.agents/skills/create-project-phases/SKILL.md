---
name: create-project-phases
description: Create a set of phases for a large project
---

Please analyze the referenced requirements document (or Linear issue) and the codebase. Your task is to:

1. Use your tools to explore the codebase and understand the existing code structure
2. Identify which files would need to be created or modified to implement this feature
3. Think about how to break this down into logical phases and tasks
4. Consider dependencies between different parts of the implementation
5. Identify any potential challenges or considerations

For now, please:
- Explore the relevant parts of the codebase
- Understand the existing patterns and conventions
- Identify the key files and components that will be involved
- Think deeply about the best approach to implement this feature

Update the given requirements document (or create a new one) to track your progress and suggested plan.

Ask one concise, high-impact question at a time that will help you improve the plan's tasks and execution details. Interview your human partner relentlessly until you reach a shared understanding of every important aspect of the plan. As you figure things out, update the details if necessary. Ask as many questions as you need to figure things out, since it improves the implementation quality.

Walk each branch of the design tree and resolve dependencies between decisions one-by-one. Every time you think you are done asking questions, review the plan file again to see if there are any more questions you might need to ask. If anything is underspecified, make sure you ask about it instead of assuming the answer.

If you are unsure whether something is already implemented in the codebase, look it up using your tools instead of asking the user.

Finally, review the plan file again, checking for any inconsistencies. Then split the work into phases for implementation. When splitting work into phases, aim for phases that are:

1. Small enough to be easily reviewable, ideally no more than a few thousand lines of code.
2. Independently mergeable to `main` on their own, without needing follow-up work to avoid breaking the product.
3. Meaningful enough to stand on their own, even if they are not yet a fully complete user-facing feature.
4. Split at natural boundaries where related bits of work can be developed independently without stepping on each other.

Prefer phases that reduce coordination risk and keep each review focused. If a split only makes sense by leaving behind a broken or unusable intermediate state, keep the work in a single phase instead. 

Phases can also split the work horizontally, such as between front-end and back-end work, or vertically, implementing a part of the full plan end-to-end.

At the end of the process, the user may ask you to add the created phases as issues in Linear or as "tim" plans with the using-tim skill. For Linear, ask which project the issues should be added to, and add each phase as a single issue. Ask the user if there should be a parent issue or not. For tim, create a single "epic" plan and then each phase as a plan below it. In both cases, set up dependencies between the issues/plans so that the order of work is clear.

Each created issue or plan should have enough detail to explain the work to be done, the requirements for it,
and suggested design patterns. The implementer will have access to the same repository you are looking at EXCEPT for the requirements document, so it is permitted to reference places in the codebase but any info from your generated plan document or the requirements document must be copied into the issue text.

Any created Linear issues should be assigned to "self".

The user may provide you with a document to read or a Linear issue that explains the existing requirements. If not,
then your first response should be to ask the user.
