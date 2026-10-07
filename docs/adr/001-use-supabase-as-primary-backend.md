# ADR-001: Use Supabase as Primary Backend Instead of Firebase

**Date:** 2026-09-13  
**Status:** Recommended  
**Decision Makers:** System Architect  

## Context

The initial plan proposed using Firebase for server/hosting and Supabase for user data storage. This creates a dual-backend architecture that adds complexity.

## Decision

**Use Supabase as the primary backend** for database, storage, and authentication. Use Firebase only for Analytics.

## Rationale

### Why Supabase Primary?

1. **PostgreSQL Benefits**
   - Complex relational data (users → programs → sessions → achievements)
   - Strong ACID guarantees for transactions (coin purchases, level ups)
   - Better for structured queries and joins
   - Built-in full-text search for community content

2. **Integrated Stack**
   - Database + Storage + Auth in one place
   - Row Level Security (RLS) for fine-grained access control
   - Real-time subscriptions for live features
   - Consistent API across all features

3. **Cost Efficiency**
   - Free tier: 500MB database, 1GB storage
   - No egress charges within same region
   - Predictable scaling costs

4. **Developer Experience**
   - Auto-generated REST and GraphQL APIs
   - Built-in SQL editor and migrations
   - Better debugging with direct SQL access

### Why Keep Firebase Analytics?

- Best-in-class mobile analytics
- Free and unlimited
- Deep integration with Google Play Console
- Existing team familiarity

## Alternatives Considered

### Alternative 1: Firebase Only
**Rejected because:**
- Firestore's document model awkward for relational data
- Complex queries require denormalization
- More expensive at scale ($0.06/100k reads)
- Harder to implement expert program following with data consistency

### Alternative 2: Keep Dual Backend (Original Plan)
**Rejected because:**
- Increased complexity: two auth systems to sync
- Data consistency challenges across systems
- Higher maintenance burden
- Confusion about which service owns what data

## Consequences

### Positive
- Simpler architecture with single source of truth
- Easier to implement transactions (follow program → update personalization)
- Better query performance for community feed and progress tracking
- Lower long-term maintenance

### Negative
- Team needs to learn Supabase (mitigated: excellent documentation)
- Firebase expertise not fully utilized (still use for Analytics)
- Slightly more setup for Google Sign-In (need to bridge Firebase Auth token to Supabase)

## Implementation Notes

### Auth Flow
```
1. User signs in with Google via Firebase Auth
2. Get Firebase ID token
3. Exchange for Supabase JWT using Firebase UID
4. Use Supabase client for all data operations
```

### Migration Path
If already started with Firebase:
1. Keep Firebase Auth as identity provider
2. Sync user records to Supabase on first login
3. All new data writes go to Supabase
4. Phase out Firebase Database over 2-3 sprints

## Review Date
Review after MVP completion or 3 months, whichever comes first.
