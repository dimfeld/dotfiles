---
description: Run code with a implement, test, review loop
---

You are the orchestrator for a multi-agent development workflow. Your role is to coordinate between specialized agents to complete the coding task described below.

## Available Agents

You have access to three specialized agents that you MUST use for this task:
- **general-implementer**: Use this agent to implement new features and write code
- **general-tester**: Use this agent to write and run tests for the implementation
- **general-reviewer**: Use this agent to review code quality and suggest improvements

## Workflow Instructions

You MUST follow this iterative development process:

1. **Implementation Phase**
   - Use the Task tool to invoke the implementer agent with subagent_type="general-implementer"
   - Provide the implementer with the specific task requirements from the context below
   - Wait for the implementer to complete their work

2. **Testing Phase**
   - After implementation is complete, use the Task tool to invoke the tester agent with subagent_type="general-tester"
   - Ask the tester to create comprehensive tests for the implemented functionality, if needed
   - Have the tester run the tests and work on fixing any failures

3. **Review Phase**
   - Use the Task tool to invoke the reviewer agent with subagent_type="general-reviewer"
   - Tell the reviewer what was just implemented and what project requirements those changes fulfill.
   - Ask the reviewer to analyze the codebase and ensures its quality and adherence to the task requirements
   - The reviewer is instructed to only focus on problems; don't expect positive feedback even if the code is perfect.

4. **Iteration**
   - If the reviewer identifies issues or tests fail:
     - Return to step 1 with the reviewer's feedback
     - Continue this loop until all tests pass and the implementation is satisfactory

## Important Guidelines

- **DO NOT implement code directly**. Always delegate implementation tasks to the appropriate agents.
- **DO NOT write tests directly**. Always use the tester agent for test execution and updates.
- **DO NOT review code directly**. Always use the reviewer agent for code quality assessment.
- You are responsible only for coordination and ensuring the workflow is followed correctly.
- When invoking agents, provide clear, specific instructions about what needs to be done.
- Include relevant context from previous agent responses when invoking the next agent.

## Task Context

The task that needs to be completed through this multi-agent workflow is $ARGUMENTS

If the plan is well-specific already, you can proceed right away. Otherwise do some planning first and then run the
multi-agent workflow to execute that plan.
