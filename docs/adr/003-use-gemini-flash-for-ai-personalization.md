# ADR-003: Use Gemini Flash for AI Workout Personalization

**Date:** 2026-09-13  
**Status:** Accepted  
**Decision Makers:** System Architect  

## Context

The application needs AI to personalize expert workout programs based on user profiles (fitness goals, limitations, equipment, etc.). We need to select an AI service that is cost-effective, fast, and capable of structured output generation.

## Decision

**Use Google Gemini 1.5 Flash API** for workout personalization, called from client-side (Flutter app).

## Rationale

### Why Gemini Flash?

1. **Generous Free Tier**
   - 15 requests per minute
   - 1 million tokens per minute
   - 1500 requests per day
   - **Sufficient for moderate user base without costs**

2. **Performance**
   - Response time: 1-2 seconds
   - Fast enough for "Personalizing..." loading state
   - Better than GPT-3.5 Turbo for structured output

3. **Structured Output**
   - Excellent JSON mode support
   - Reliable schema adherence
   - Good for workout program transformations

4. **Context Window**
   - 1M token context (more than enough for program + user profile)
   - Can include detailed exercise descriptions

### Client-Side vs Server-Side

**Decision: Client-Side** (call from Flutter app)

**Why?**
- Simpler architecture (no backend API needed)
- Free tier quotas per API key (not per user)
- Faster development (no server middleware)
- Can implement request queuing in app

**Trade-offs:**
- API key exposed in app (mitigate with Firebase App Check)
- Harder to implement rate limiting per user
- Cannot easily switch AI providers without app update

## Alternatives Considered

### Alternative 1: ChatGPT (GPT-3.5 Turbo)
**Rejected because:**
- Only $5 free credit (runs out quickly)
- $0.50 per 1M input tokens after free tier
- No generous ongoing free tier
- Slower API response times in Southeast Asia

### Alternative 2: Claude 3.5 Haiku via Anthropic API
**Rejected because:**
- Very limited free tier (few credits)
- $0.25 per 1M input tokens
- Better quality but overkill for this use case
- Higher cost at scale

### Alternative 3: Self-Hosted LLM (Llama 3, etc.)
**Rejected because:**
- Requires server infrastructure
- Deployment complexity
- Quality not comparable to Gemini for structured tasks
- Higher total cost of ownership

### Alternative 4: Rule-Based System (No AI)
**Considered but insufficient:**
- Hard to capture nuance of personalization
- Many edge cases (combinations of limitations + equipment)
- Less flexible for future enhancements
- Poor user experience (feels rigid)

## Cost Estimation

### Free Tier Capacity
- 15 requests/minute = 900 requests/hour = 21,600 requests/day
- Average use case: 1-2 personalizations per user per week
- **Supports ~1,500 active users comfortably within free tier**

### Paid Tier Cost (if needed)
- Gemini Flash pricing: $0.075 per 1M input tokens, $0.30 per 1M output tokens
- Average request: ~2k input tokens, ~500 output tokens
- Cost per personalization: ~$0.00030
- **1000 personalizations = $0.30**

## Consequences

### Positive
- Zero cost for early users
- Fast response times
- High-quality personalization
- Easy to implement
- Scalable to thousands of users before costs kick in

### Negative
- API key in client app (security risk)
- Vendor lock-in to Google ecosystem
- Limited control over rate limiting
- Must handle API failures gracefully
- Cannot easily audit/log all requests

### Mitigations
- Implement Firebase App Check immediately
- Build abstraction layer for AI calls (easier to swap later)
- Cache results aggressively
- Implement offline fallback (use program as-is without personalization)

## Fallback Strategy

If Gemini API is unavailable or quota exceeded:
1. Return original program with disclaimer: "Using expert's original program"
2. Queue personalization for retry
3. Notify user when personalized version ready
4. Consider temporary switch to rule-based adjustments

## Success Metrics

| Metric | Target |
|--------|--------|
| API success rate | >99% |
| Average response time | <3 seconds |
| User satisfaction with personalization | >4.0/5.0 |
| API cost per active user per month | <$0.10 |

## Migration Path

If we exceed free tier or need better control:
1. **Phase 1:** Move to server-side proxy (Cloud Run)
2. **Phase 2:** Implement per-user rate limiting
3. **Phase 3:** Consider fine-tuned model or alternative provider

## Review Date
Review after reaching 500 active users or 3 months, whichever comes first.
