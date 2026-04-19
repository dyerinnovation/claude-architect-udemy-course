# Scenario Lab: Multi-Agent Research Pipeline

## Overview

In this lab, you will architect a sophisticated multi-agent research system where a coordinator agent spawns multiple specialized subagents to investigate different aspects of a research question in parallel. The coordinator aggregates their findings, synthesizes insights, and generates a comprehensive report with explicit coverage gap annotations and built-in crash recovery.

**Key Architecture Pattern:** Parallel subagent spawning, structured output mappings, error propagation, state manifests for recovery.

---

## Learning Objectives

By completing this lab, you will demonstrate the ability to:

1. **Design a multi-agent architecture** with a coordinator and specialized subagents
2. **Spawn subagents in parallel** from a single coordinator response without sequential blocking
3. **Define structured claim-source mappings** that explicitly link research claims to their sources
4. **Implement error propagation** that captures and reports when a subagent fails
5. **Design synthesis logic** that identifies gaps in coverage and annotates them
6. **Build crash recovery mechanisms** using agent state manifests stored locally
7. **Orchestrate complex research workflows** across multiple models and API calls

**Exam Connections:** Domain 1 (Agent Design & Routing), Domain 2 (Multi-turn Conversations & State), Domain 5 (System Design & Scaling)

---

## Prerequisites

### Tools & APIs
- **Claude API** with batch processing support (for parallel calls)
- **Python 3.8+** with the Anthropic SDK
- **JSON schema** understanding for structured outputs
- **Local file system** for state manifest storage

### Knowledge
- Understanding of agent coordination patterns (Module 2)
- Familiarity with Claude's response_format for structured outputs (Module 3)
- Basic knowledge of error handling and resilience patterns

### Setup
```bash
pip install anthropic pydantic

# Set API key
export CLAUDE_API_KEY="your-key-here"
```

---

## Step-by-Step Instructions

### Step 1: Define Subagent Responsibilities

Create a file `agents.py` that defines the responsibilities and prompts for each specialized subagent.

**Scaffolding Code:**

```python
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
from datetime import datetime
import json
import uuid

class Claim(BaseModel):
    """A single research claim with source attribution."""
    text: str
    confidence: str  # "high", "medium", "low"
    sources: List[str]  # URLs or citations
    date_accessed: str  # ISO 8601

class SubagentOutput(BaseModel):
    """Structured output from a subagent."""
    agent_name: str
    topic: str
    claims: List[Claim]
    summary: str
    confidence_overall: str
    error: Optional[str] = None
    tokens_used: Dict[str, int] = {}

class SubagentDefinition:
    """Encapsulates a subagent's role and instructions."""

    def __init__(self, name: str, topic: str, instructions: str):
        self.name = name
        self.topic = topic
        self.instructions = instructions

# Define the four specialized subagents
WEB_SEARCH_AGENT = SubagentDefinition(
    name="web-search",
    topic="recent_news_and_articles",
    instructions="""You are a web research specialist. Your task is to find recent news articles, blog posts, and online resources about the given topic.

Focus on:
- Recent publications (last 3 months preferred)
- Reputable sources (news outlets, industry publications, academic institutions)
- Diverse perspectives

For each finding, provide:
- The claim (what did you learn?)
- Confidence level (high/medium/low based on source credibility)
- Source URL or citation

Output your findings as a JSON object with the structure:
{
    "claims": [
        {
            "text": "specific claim here",
            "confidence": "high",
            "sources": ["https://example.com/article"]
        }
    ],
    "summary": "brief overview of what you found"
}"""
)

DOCUMENT_ANALYSIS_AGENT = SubagentDefinition(
    name="document-analysis",
    topic="detailed_source_analysis",
    instructions="""You are a document analysis specialist. Your task is to deeply analyze key documents, papers, reports, and long-form content about the given topic.

Focus on:
- Academic papers and whitepapers
- Official reports and case studies
- Industry benchmarks and standards

For each finding, provide:
- The claim (what does the document say?)
- Confidence level (high/medium/low based on methodology and peer review)
- Document citation

Output your findings as a JSON object with the structure:
{
    "claims": [
        {
            "text": "specific claim from the document",
            "confidence": "high",
            "sources": ["Author Name. Title. Publication. Year."]
        }
    ],
    "summary": "overview of key themes across documents"
}"""
)

TREND_ANALYSIS_AGENT = SubagentDefinition(
    name="trend-analysis",
    topic="emerging_trends_and_patterns",
    instructions="""You are a trend analyst. Your task is to identify emerging patterns, trends, and forecasts about the given topic.

Focus on:
- Emerging technologies or methodologies
- Market or industry shifts
- Predictions from experts and analysts
- Pattern changes over time

For each finding, provide:
- The claim (what trend did you identify?)
- Confidence level (high/medium/low based on evidence and consensus)
- Sources (expert citations, reports)

Output your findings as a JSON object with the structure:
{
    "claims": [
        {
            "text": "trend or pattern identified",
            "confidence": "medium",
            "sources": ["Expert Name. Analysis. Platform."]
        }
    ],
    "summary": "synthesis of key trends"
}"""
)

SYNTHESIS_AGENT = SubagentDefinition(
    name="synthesis",
    topic="cross_cutting_insights",
    instructions="""You are a synthesis specialist. You will receive findings from other researchers.

Your task is to:
1. Identify themes that appear across multiple sources
2. Highlight contradictions or tensions in the findings
3. Identify gaps where information is missing
4. Synthesize a coherent narrative

For each insight, provide:
- The claim (what insight emerged?)
- Confidence level (high/medium/low)
- Supporting sources

Also explicitly list coverage gaps:
- What questions remain unanswered?
- What areas lack source diversity?
- What needs further investigation?

Output your findings as a JSON object with the structure:
{
    "cross_cutting_insights": [
        {
            "text": "insight from synthesis",
            "confidence": "high",
            "sources": ["multiple agents' findings"]
        }
    ],
    "coverage_gaps": [
        "Gap 1: What about X?",
        "Gap 2: Limited sources on Y"
    ],
    "summary": "overall synthesis"
}"""
)
```

**Task:** Review the four subagent definitions. For the topic "artificial intelligence in healthcare," what specific subtopics would each agent investigate? (Answer: Web Search → recent healthcare AI news; Document Analysis → clinical trials & FDA papers; Trend Analysis → emerging AI modalities in medicine; Synthesis → connecting patterns across all findings.)

---

### Step 2: Implement Subagent Spawning with Parallel Execution

Create a function that spawns all subagents in a single coordinator response, using batch processing to parallelize the calls.

**Scaffolding Code:**

```python
from anthropic import Anthropic
import asyncio
from concurrent.futures import ThreadPoolExecutor, as_completed
import time

client = Anthropic()

class ResearchCoordinator:
    """Orchestrates the multi-agent research pipeline."""

    def __init__(self, research_question: str):
        self.research_question = research_question
        self.session_id = str(uuid.uuid4())[:8]
        self.subagent_results = {}
        self.state_manifest = {}
        self.start_time = datetime.now()

    def create_coordinator_prompt(self) -> str:
        return f"""You are a research coordinator. Your task is to orchestrate an investigation into the following research question:

"{self.research_question}"

You will coordinate four specialized research agents:
1. Web Search Agent - finds recent news and online content
2. Document Analysis Agent - deep-dives into academic/technical documents
3. Trend Analysis Agent - identifies emerging patterns and forecasts
4. Synthesis Agent - combines findings and highlights gaps

Explicitly trigger each agent to begin their investigation. For each agent, provide:
- Clear, specific instructions relevant to the research question
- Context about what you need them to focus on

Your response should take the form of delegation messages to each agent. You don't need to wait for them - just initiate all four in your response.

Format your response as:
---
TO: web-search
QUERY: [specific question for this agent]

TO: document-analysis
QUERY: [specific question for this agent]

TO: trend-analysis
QUERY: [specific question for this agent]

TO: synthesis
QUERY: [specific question for this agent about integrating findings]
---"""

    def parse_coordinator_response(self, response_text: str) -> Dict[str, str]:
        """Extract agent queries from coordinator response."""
        agents = {}
        lines = response_text.split("\n")
        current_agent = None
        current_query = []

        for line in lines:
            if line.startswith("TO:"):
                if current_agent:
                    agents[current_agent] = "\n".join(current_query).strip()
                current_agent = line.replace("TO:", "").strip()
                current_query = []
            elif line.startswith("QUERY:"):
                current_query.append(line.replace("QUERY:", "").strip())
            elif current_agent and line.strip():
                current_query.append(line.strip())

        if current_agent:
            agents[current_agent] = "\n".join(current_query).strip()

        return agents

    def run_subagent(self, agent_def: SubagentDefinition, query: str) -> SubagentOutput:
        """Execute a single subagent with structured output."""
        print(f"  Spawning {agent_def.name} agent...")

        try:
            response = client.messages.create(
                model="claude-sonnet-4-6",
                max_tokens=1500,
                system=agent_def.instructions,
                messages=[
                    {
                        "role": "user",
                        "content": f"Research question: {self.research_question}\n\nYour specific focus: {query}"
                    }
                ]
            )

            # Parse response
            raw_output = response.content[0].text if response.content else ""

            # Extract JSON from response
            try:
                # Try to parse as JSON directly
                json_start = raw_output.find("{")
                json_end = raw_output.rfind("}") + 1
                if json_start >= 0 and json_end > json_start:
                    json_str = raw_output[json_start:json_end]
                    data = json.loads(json_str)
                else:
                    data = {"error": "Could not parse JSON from response"}
            except json.JSONDecodeError:
                data = {"error": f"Invalid JSON: {raw_output[:100]}"}

            # Convert to SubagentOutput
            output = SubagentOutput(
                agent_name=agent_def.name,
                topic=agent_def.topic,
                claims=[
                    Claim(
                        text=c["text"],
                        confidence=c.get("confidence", "medium"),
                        sources=c.get("sources", []),
                        date_accessed=datetime.now().isoformat()
                    )
                    for c in data.get("claims", [])
                ],
                summary=data.get("summary", ""),
                confidence_overall=data.get("confidence", "medium"),
                tokens_used={
                    "input": response.usage.input_tokens,
                    "output": response.usage.output_tokens
                }
            )

            return output

        except Exception as e:
            return SubagentOutput(
                agent_name=agent_def.name,
                topic=agent_def.topic,
                claims=[],
                summary="",
                confidence_overall="low",
                error=str(e),
                tokens_used={"error": 1}
            )

    def spawn_all_subagents(self, agent_queries: Dict[str, str]):
        """Execute all subagents in parallel using ThreadPoolExecutor."""
        print(f"\nSpawning {len(agent_queries)} subagents in parallel...\n")

        agent_map = {
            "web-search": WEB_SEARCH_AGENT,
            "document-analysis": DOCUMENT_ANALYSIS_AGENT,
            "trend-analysis": TREND_ANALYSIS_AGENT,
            "synthesis": SYNTHESIS_AGENT
        }

        with ThreadPoolExecutor(max_workers=4) as executor:
            # Submit all tasks
            futures = {}
            for agent_name, query in agent_queries.items():
                if agent_name in agent_map:
                    agent_def = agent_map[agent_name]
                    future = executor.submit(self.run_subagent, agent_def, query)
                    futures[future] = agent_name

            # Collect results as they complete
            for future in as_completed(futures):
                agent_name = futures[future]
                try:
                    result = future.result()
                    self.subagent_results[agent_name] = result
                    status = f"✓ {agent_name}" if not result.error else f"✗ {agent_name}: {result.error}"
                    print(f"  {status}")
                except Exception as e:
                    print(f"  ✗ {agent_name}: {e}")
                    self.subagent_results[agent_name] = SubagentOutput(
                        agent_name=agent_name,
                        topic="unknown",
                        claims=[],
                        summary="",
                        confidence_overall="low",
                        error=str(e)
                    )

    def generate_report(self) -> str:
        """Compile findings into a comprehensive report."""
        report = []
        report.append(f"# Research Report: {self.research_question}")
        report.append(f"\nSession ID: {self.session_id}")
        report.append(f"Generated: {datetime.now().isoformat()}\n")

        report.append("## Executive Summary\n")
        for agent_name, output in self.subagent_results.items():
            if not output.error:
                report.append(f"**{agent_name}:** {output.summary}")
        report.append("")

        report.append("## Detailed Findings by Topic\n")
        for agent_name, output in self.subagent_results.items():
            if output.error:
                report.append(f"### {agent_name}\n")
                report.append(f"⚠️ ERROR: {output.error}\n")
                continue

            report.append(f"### {output.topic.replace('_', ' ').title()}\n")

            for claim in output.claims:
                source_str = ", ".join(claim.sources[:2]) if claim.sources else "Unknown"
                report.append(
                    f"- **[{claim.confidence.upper()}]** {claim.text}\n"
                    f"  _Source: {source_str}_\n"
                )

            report.append("")

        # Coverage gap analysis
        report.append("## Coverage Gaps & Limitations\n")
        synthesis_output = self.subagent_results.get("synthesis")
        if synthesis_output and not synthesis_output.error:
            gaps = json.loads(synthesis_output.summary).get("coverage_gaps", [])
            for gap in gaps:
                report.append(f"- {gap}\n")
        else:
            report.append("- No synthesis agent available to identify gaps\n")

        report.append("\n## Confidence Assessment\n")
        for agent_name, output in self.subagent_results.items():
            if not output.error:
                report.append(f"- {agent_name}: {output.confidence_overall.upper()}\n")

        report.append(f"\n## Token Usage\n")
        total_tokens = 0
        for agent_name, output in self.subagent_results.items():
            if output.tokens_used:
                tokens = output.tokens_used.get("input", 0) + output.tokens_used.get("output", 0)
                total_tokens += tokens
                report.append(f"- {agent_name}: {tokens} tokens\n")
        report.append(f"\n**Total:** {total_tokens} tokens\n")

        return "\n".join(report)
```

**Task:** In the `spawn_all_subagents` method, the synthesis agent runs in parallel with the others. How would you modify this to run synthesis after the other three agents complete? (Hint: Use asyncio or add a dependency graph.)

---

### Step 3: Implement Structured Error Propagation

Create a system that captures subagent failures and propagates them forward for explicit reporting.

**Scaffolding Code:**

```python
class ErrorPropagationHandler:
    """Manages error information flow through the pipeline."""

    def __init__(self):
        self.errors = []
        self.partial_results = {}

    def record_error(self, agent_name: str, error_type: str, message: str, context: dict = None):
        """Log an error with context."""
        error_record = {
            "timestamp": datetime.now().isoformat(),
            "agent": agent_name,
            "type": error_type,
            "message": message,
            "context": context or {},
            "recoverable": error_type in ["timeout", "rate_limit", "transient_failure"]
        }
        self.errors.append(error_record)

    def get_error_summary(self) -> str:
        """Generate a summary of all errors for the report."""
        if not self.errors:
            return "✓ No errors encountered during research.\n"

        summary = f"⚠️ {len(self.errors)} error(s) encountered:\n"
        for error in self.errors:
            summary += f"\n- **{error['agent']}** ({error['type']}): {error['message']}\n"
            if error['recoverable']:
                summary += "  → This error may be recovered by re-running the agent.\n"

        return summary

    def should_retry(self, agent_name: str) -> bool:
        """Determine if an agent should be retried."""
        agent_errors = [e for e in self.errors if e['agent'] == agent_name]
        return any(e['recoverable'] for e in agent_errors)

def validate_subagent_output(output: SubagentOutput) -> tuple[bool, str]:
    """Validate that a subagent output meets minimum standards."""
    if output.error:
        return False, f"Agent failed: {output.error}"

    if not output.claims:
        return False, "No claims produced"

    if output.confidence_overall == "low" and len(output.claims) < 2:
        return False, "Low confidence with insufficient evidence"

    return True, "Valid"

# Modify ResearchCoordinator to use error handling
class ResearchCoordinatorWithErrorHandling(ResearchCoordinator):

    def __init__(self, research_question: str):
        super().__init__(research_question)
        self.error_handler = ErrorPropagationHandler()

    def run_subagent_with_retry(self, agent_def: SubagentDefinition, query: str, max_retries: int = 1) -> SubagentOutput:
        """Run a subagent with automatic retry on failure."""
        for attempt in range(max_retries + 1):
            try:
                output = self.run_subagent(agent_def, query)

                valid, reason = validate_subagent_output(output)
                if not valid:
                    self.error_handler.record_error(
                        agent_def.name,
                        "validation_failure",
                        reason,
                        {"attempt": attempt, "claims_count": len(output.claims)}
                    )
                    if attempt < max_retries:
                        print(f"    Retrying {agent_def.name}... (attempt {attempt + 1})")
                        time.sleep(1)  # Back off before retry
                        continue
                    else:
                        return output

                return output

            except Exception as e:
                self.error_handler.record_error(
                    agent_def.name,
                    "execution_error",
                    str(e),
                    {"attempt": attempt}
                )
                if attempt < max_retries:
                    print(f"    Retrying {agent_def.name}... (attempt {attempt + 1})")
                    time.sleep(1)
                    continue
                else:
                    raise

    def generate_report(self) -> str:
        """Include error summary in report."""
        report = super().generate_report()

        # Insert error section after executive summary
        error_summary = self.error_handler.get_error_summary()
        report = report.replace(
            "## Detailed Findings by Topic\n",
            f"## Error Summary\n\n{error_summary}\n## Detailed Findings by Topic\n"
        )

        return report
```

**Task:** Modify the validation logic to mark a failure as "recoverable" if it's due to rate limiting vs. a schema error. How would you implement different retry strategies for each?

---

### Step 4: Implement State Manifests for Crash Recovery

Create a system that saves the research state so it can be recovered if a process fails midway.

**Scaffolding Code:**

```python
import pickle
import os

class StateManifest:
    """Serializable snapshot of research progress for recovery."""

    def __init__(self, session_id: str):
        self.session_id = session_id
        self.created_at = datetime.now().isoformat()
        self.last_updated = datetime.now().isoformat()
        self.completed_agents = []
        self.failed_agents = []
        self.pending_agents = []
        self.results = {}
        self.coordinator_message = ""

    def to_dict(self) -> dict:
        return {
            "session_id": self.session_id,
            "created_at": self.created_at,
            "last_updated": self.last_updated,
            "completed_agents": self.completed_agents,
            "failed_agents": self.failed_agents,
            "pending_agents": self.pending_agents,
            "results": self.results,
            "coordinator_message": self.coordinator_message
        }

    def save(self, directory: str = ".research_cache"):
        """Persist state to disk."""
        os.makedirs(directory, exist_ok=True)
        manifest_path = os.path.join(directory, f"{self.session_id}_manifest.json")

        with open(manifest_path, "w") as f:
            json.dump(self.to_dict(), f, indent=2, default=str)

        print(f"  State saved: {manifest_path}")

    @classmethod
    def load(cls, session_id: str, directory: str = ".research_cache") -> Optional["StateManifest"]:
        """Load state from disk."""
        manifest_path = os.path.join(directory, f"{session_id}_manifest.json")

        if not os.path.exists(manifest_path):
            return None

        with open(manifest_path, "r") as f:
            data = json.load(f)

        manifest = cls(session_id)
        manifest.created_at = data["created_at"]
        manifest.last_updated = data["last_updated"]
        manifest.completed_agents = data["completed_agents"]
        manifest.failed_agents = data["failed_agents"]
        manifest.pending_agents = data["pending_agents"]
        manifest.results = data["results"]
        manifest.coordinator_message = data["coordinator_message"]

        return manifest

class ResearchCoordinatorWithRecovery(ResearchCoordinatorWithErrorHandling):

    def __init__(self, research_question: str, session_id: str = None, recover: bool = False):
        if session_id and recover:
            manifest = StateManifest.load(session_id)
            if manifest:
                print(f"Recovering from session {session_id}...")
                self.research_question = research_question
                self.session_id = session_id
                self.state_manifest = manifest
                self.subagent_results = manifest.results
                return

        super().__init__(research_question)
        self.state_manifest = StateManifest(self.session_id)

    def update_state(self, agent_name: str, output: SubagentOutput):
        """Update state after an agent completes."""
        self.state_manifest.last_updated = datetime.now().isoformat()

        if output.error:
            self.state_manifest.failed_agents.append(agent_name)
            self.state_manifest.pending_agents = [
                a for a in self.state_manifest.pending_agents if a != agent_name
            ]
        else:
            self.state_manifest.completed_agents.append(agent_name)
            self.state_manifest.pending_agents = [
                a for a in self.state_manifest.pending_agents if a != agent_name
            ]
            # Store serializable version
            self.state_manifest.results[agent_name] = {
                "agent_name": output.agent_name,
                "topic": output.topic,
                "claims": [
                    {
                        "text": c.text,
                        "confidence": c.confidence,
                        "sources": c.sources,
                        "date_accessed": c.date_accessed
                    }
                    for c in output.claims
                ],
                "summary": output.summary,
                "confidence_overall": output.confidence_overall,
                "error": output.error
            }

        self.state_manifest.save()

    def spawn_all_subagents_with_recovery(self, agent_queries: Dict[str, str]):
        """Spawn agents with state persistence."""
        print(f"\nSpawning subagents with crash recovery (session: {self.session_id})...\n")

        agent_map = {
            "web-search": WEB_SEARCH_AGENT,
            "document-analysis": DOCUMENT_ANALYSIS_AGENT,
            "trend-analysis": TREND_ANALYSIS_AGENT,
            "synthesis": SYNTHESIS_AGENT
        }

        # Initialize pending agents
        self.state_manifest.pending_agents = list(agent_queries.keys())
        self.state_manifest.save()

        with ThreadPoolExecutor(max_workers=4) as executor:
            futures = {}
            for agent_name, query in agent_queries.items():
                if agent_name in agent_map:
                    agent_def = agent_map[agent_name]
                    future = executor.submit(self.run_subagent_with_retry, agent_def, query)
                    futures[future] = agent_name

            for future in as_completed(futures):
                agent_name = futures[future]
                try:
                    result = future.result()
                    self.subagent_results[agent_name] = result
                    self.update_state(agent_name, result)
                    status = f"✓ {agent_name}" if not result.error else f"✗ {agent_name}"
                    print(f"  {status}")
                except Exception as e:
                    self.update_state(agent_name, SubagentOutput(
                        agent_name=agent_name,
                        topic="unknown",
                        claims=[],
                        summary="",
                        confidence_overall="low",
                        error=str(e)
                    ))
                    print(f"  ✗ {agent_name}: {e}")
```

**Task:** Write a script that checks for incomplete sessions and asks the user if they want to recover. Use StateManifest.load() to find all incomplete sessions in the cache directory.

---

### Step 5: Integrate Coverage Gap Annotations

Enhance the synthesis output to explicitly identify areas where research is incomplete.

**Scaffolding Code:**

```python
class CoverageAnalyzer:
    """Analyzes gaps in research coverage."""

    @staticmethod
    def compute_coverage_gaps(
        web_search_output: SubagentOutput,
        document_output: SubagentOutput,
        trend_output: SubagentOutput
    ) -> List[str]:
        """
        Analyze the coverage provided by the first three agents to identify gaps.
        """
        gaps = []

        # Check source diversity
        all_sources = []
        for output in [web_search_output, document_output, trend_output]:
            if not output.error:
                for claim in output.claims:
                    all_sources.extend(claim.sources)

        if not all_sources:
            gaps.append("No sources found across all research agents")
        elif len(set(all_sources)) < 3:
            gaps.append("Limited source diversity - recommendations rely on fewer than 3 unique sources")

        # Check confidence distribution
        low_confidence = sum(
            1 for output in [web_search_output, document_output, trend_output]
            if not output.error and output.confidence_overall == "low"
        )
        if low_confidence >= 2:
            gaps.append(f"{low_confidence} research agents have low confidence - findings need validation")

        # Check for agent failures
        failed = [
            output.agent_name for output in [web_search_output, document_output, trend_output]
            if output.error
        ]
        if failed:
            gaps.append(f"Research incomplete: {', '.join(failed)} agents failed - missing {len(failed)}/3 perspectives")

        # Check claim count
        total_claims = sum(
            len(output.claims) for output in [web_search_output, document_output, trend_output]
            if not output.error
        )
        if total_claims < 5:
            gaps.append("Limited evidence: fewer than 5 claims found - consider broader search")

        # Recency check
        recent_claims = sum(
            1 for output in [web_search_output, document_output, trend_output]
            if not output.error
            for claim in output.claims
            if claim.date_accessed > (datetime.now() - timedelta(days=30)).isoformat()
        )
        if recent_claims == 0:
            gaps.append("No recent information (last 30 days) - research may be stale")

        return gaps if gaps else ["No significant coverage gaps identified"]

def annotate_report_with_gaps(report: str, gaps: List[str]) -> str:
    """Add gap annotations to report."""
    gap_section = "\n## Coverage Gaps & Research Limitations\n\n"
    gap_section += "⚠️ The following gaps were identified:\n\n"
    for gap in gaps:
        gap_section += f"- {gap}\n"

    gap_section += "\n### Recommended Follow-up Investigation\n\n"
    gap_section += "To fill these gaps, consider:\n"
    gap_section += "- Expanding search queries to include related terms\n"
    gap_section += "- Seeking expert interviews or primary sources\n"
    gap_section += "- Conducting domain-specific deep dives on areas with low coverage\n\n"

    # Insert before the final token usage section
    report = report.replace(
        "\n## Token Usage\n",
        gap_section + "## Token Usage\n"
    )

    return report
```

**Task:** Add a "source domain diversity" gap that flags if all sources come from a single domain (e.g., all from medium.com). How would you implement this check?

---

### Step 6: Run Complete Pipeline

Create a main execution function that orchestrates the entire research pipeline.

**Scaffolding Code:**

```python
def run_research_pipeline(research_question: str, recover_session: str = None) -> str:
    """Execute complete research pipeline with recovery support."""

    print(f"\n{'='*70}")
    print(f"RESEARCH PIPELINE: {research_question}")
    print(f"{'='*70}\n")

    # Initialize coordinator (with recovery if specified)
    coordinator = ResearchCoordinatorWithRecovery(
        research_question,
        session_id=recover_session,
        recover=bool(recover_session)
    )

    # Step 1: Get coordinator delegation instructions
    print("Step 1: Coordinator parsing research question...\n")
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1000,
        messages=[
            {"role": "user", "content": coordinator.create_coordinator_prompt()}
        ]
    )

    coordinator_response = response.content[0].text
    print(f"Coordinator response:\n{coordinator_response}\n")

    agent_queries = coordinator.parse_coordinator_response(coordinator_response)
    coordinator.state_manifest.coordinator_message = coordinator_response
    coordinator.state_manifest.save()

    # Step 2: Spawn all subagents in parallel
    print("Step 2: Spawning specialized research agents...\n")
    coordinator.spawn_all_subagents_with_recovery(agent_queries)

    # Step 3: Analyze coverage gaps
    print("\nStep 3: Analyzing coverage gaps...\n")
    gaps = CoverageAnalyzer.compute_coverage_gaps(
        coordinator.subagent_results.get("web-search") or SubagentOutput(
            agent_name="web-search", topic="", claims=[], summary="", confidence_overall="low", error="Not run"
        ),
        coordinator.subagent_results.get("document-analysis") or SubagentOutput(
            agent_name="document-analysis", topic="", claims=[], summary="", confidence_overall="low", error="Not run"
        ),
        coordinator.subagent_results.get("trend-analysis") or SubagentOutput(
            agent_name="trend-analysis", topic="", claims=[], summary="", confidence_overall="low", error="Not run"
        )
    )

    # Step 4: Generate comprehensive report
    print("Step 4: Generating research report...\n")
    report = coordinator.generate_report()
    report = annotate_report_with_gaps(report, gaps)

    # Step 5: Save report
    report_path = f".research_output/{coordinator.session_id}_report.md"
    os.makedirs(".research_output", exist_ok=True)

    with open(report_path, "w") as f:
        f.write(report)

    print(f"\n{'='*70}")
    print(f"✓ Research complete. Session ID: {coordinator.session_id}")
    print(f"✓ Report saved: {report_path}")
    print(f"{'='*70}\n")

    return report

# Test scenarios
if __name__ == "__main__":
    test_questions = [
        "What are the latest developments in quantum computing as of March 2024?",
        "How are large language models being applied in scientific research?",
        "What are the emerging practices in sustainable software engineering?"
    ]

    for question in test_questions:
        report = run_research_pipeline(question)
        print(report)
```

---

## Expected Outcomes & Success Criteria

### Successful Pipeline Behavior
1. **Parallel Execution:** All four subagents run simultaneously in separate threads
2. **Error Resilience:** If one subagent fails, others complete; error is recorded and reported
3. **Structured Output:** Each subagent returns claims with confidence levels and sources
4. **Coverage Analysis:** Pipeline identifies gaps such as:
   - "Only 2 of 4 agents succeeded"
   - "Limited source diversity"
   - "Low confidence across findings"
5. **Crash Recovery:** If process is interrupted, state manifest allows resuming from the last successful agent
6. **Clear Report:** Final report includes executive summary, detailed findings, gap analysis, and recommendations

### Test Pass Criteria
- All 3 test questions complete without exceptions
- Report includes findings from at least 2 subagents per question
- Coverage gaps are identified and documented
- Session ID allows recovery if manually interrupted
- No sensitive data in outputs; all sources are properly cited

### Sample Report Output
```
# Research Report: What are the latest developments in quantum computing?

Session ID: a1b2c3d4
Generated: 2024-03-26T...

## Executive Summary
**web-search:** Recent quantum computing breakthroughs include advances in error correction...
**document-analysis:** Academic literature focuses on superconducting qubits and ion traps...
**trend-analysis:** Major trend: Shift from hardware-focused to software-algorithm research...

## Coverage Gaps & Research Limitations

⚠️ The following gaps were identified:
- Limited source diversity - recommendations rely on fewer than 3 unique sources
- No recent information (last 30 days) - research may be stale

### Recommended Follow-up Investigation
- Expand search to include preprints from arXiv
- Interview quantum computing researchers
```

---

## Common Mistakes to Avoid

1. **Sequential execution instead of parallel:** Waiting for one agent to finish before starting another defeats the purpose
2. **Lost partial results on failure:** Not persisting state before spawning agents means losing progress
3. **Ignoring error types:** Treating all errors as permanent when some (timeouts) are recoverable
4. **Over-aggregation:** Blindly combining claims without noting conflicts or source quality
5. **No synthesis step:** Leaving it to the human to connect findings; agent should do this
6. **Timestamp drift:** Not checking if recovered session is stale (e.g., re-running with 1-month-old cached results)
7. **Token cost explosion:** Not tracking token usage; parallel execution can be expensive

---

## Connection to Exam Concepts

**Domain 1: Agent Design & Routing**
- **Task 1.1:** Design multi-agent systems with specialized roles
  - Demonstrates coordinator + specialized subagent pattern
- **Task 1.4:** Handle heterogeneous tool outputs
  - Shows claim-source mapping and structured output validation

**Domain 2: Multi-turn Conversations & State Management**
- **Task 2.1:** Maintain conversation state across turns
  - State manifests persist research progress across crashes
- **Task 2.2:** Implement recovery mechanisms
  - Crash recovery using StateManifest; resuming incomplete research

**Domain 5: System Design & Scaling**
- **Task 5.2:** Design systems for parallel execution
  - Multi-threaded subagent spawning with ThreadPoolExecutor
- **Task 5.3:** Handle error propagation in distributed systems
  - Error tracking, reporting, and recovery

**Relevant Course Modules:** Module 2 (Multi-Agent Design), Module 3 (Structured Outputs), Module 5 (State & Recovery)

---

## Estimated Time to Complete

- **Reading & setup:** 15 minutes
- **Steps 1-2 (Agent definitions & spawning):** 25 minutes
- **Step 3 (Error handling):** 15 minutes
- **Step 4 (State manifests):** 20 minutes
- **Step 5 (Coverage analysis):** 15 minutes
- **Step 6 (Integration & testing):** 20 minutes
- **Total:** 110 minutes (1.8 hours)

**Suggested Checkpoint:** After Step 2, verify that all four agents spawn in parallel and complete successfully.

---

## Additional Challenges (Optional)

1. **Implement agent dependency graphs** for tasks that should run sequentially (e.g., synthesis after others)
2. **Add a "quality review" agent** that evaluates other agents' outputs for credibility
3. **Implement incremental report generation** that updates reports as agents complete
4. **Design a cost-optimization strategy** that aborts low-confidence agents early
5. **Build a "feedback loop"** where synthesis results are sent back to other agents for refinement
6. **Add human-in-the-loop** sections where agents ask clarifying questions before proceeding
