---
description: Update an rmplan plan file
---

Please examine the file referenced and make the requested updates to the markdown details, tasks, and steps (if applicable), looking at the existing codebase and thinking about how to
accomplish the goal within it.

The file and update to perform is $ARGUMENTS

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

