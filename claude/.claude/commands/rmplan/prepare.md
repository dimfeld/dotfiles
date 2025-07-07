---
description: Create tasks for an rmplan plan file
---

Please examine the file $ARGUMENTS and look at it in context of the codebase. Make these updates:


If the file needs tasks or if the tasks have steps, think about how to implement them in the codebase and add them to the file. Think hard and break each task
down into steps according to the schema below.

The zod schema of the plan file frontmatter section is:
```
z
  .object({
    title: z.string().optional(),
    goal: z.string(),
    id: z.coerce.number().int().positive().optional(),
    status: statusSchema.default('pending').optional(),
    priority: prioritySchema.optional(),
    container: z.boolean().default(false).optional(),
    dependencies: z.array(z.coerce.number().int().positive()).default([]).optional(),
    parent: z.coerce.number().int().positive().optional(),
    issue: z.array(z.url()).default([]).optional(),
    pullRequest: z.array(z.url()).default([]).optional(),
    docs: z.array(z.string()).default([]).optional(),
    assignedTo: z.string().optional(),
    planGeneratedAt: z.string().datetime().optional(),
    promptsGeneratedAt: z.string().datetime().optional(),
    createdAt: z.string().datetime().optional(),
    updatedAt: z.string().datetime().optional(),
    project: z
      .object({
        title: z.string(),
        goal: z.string(),
        details: z.string(),
      })
      .optional(),
    tasks: z.array(
      z.object({
        title: z.string(),
        description: z.string(),
        files: z.array(z.string()).default([]).optional(),
        examples: z.array(z.string()).optional(),
        docs: z.array(z.string()).default([]).optional(),
        done: z.boolean().default(false).optional(),
        steps: z
          .array(
            z.object({
              prompt: z.string(),
              examples: z.array(z.string()).optional(),
              done: z.boolean().default(false),
            })
          )
          .default([]),
      })
    ),
    baseBranch: z.string().optional(),
    changedFiles: z.array(z.string()).default([]).optional(),
    rmfilter: z.array(z.string()).default([]).optional().description('Paths in the codebase to reference'),
  })
```
