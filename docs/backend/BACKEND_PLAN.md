# Backend Improvement Roadmap

## 1. Category Standardization Strategy
**Goal:** Ensure the mobile app receives clean, predictable category data to prevent "Other" or unknown category issues.

- [ ] **Normalization Middleware:**
  - [ ] **Input:** Receive raw category tags from OpenFoodFacts (e.g., `en:breakfast-cereals`, `tr:kahvaltılık-gevrekler`).
  - [ ] **Mapping Logic:** Create a robust mapping layer that converts these raw tags to SmartDolap's internal keys:
    - `dairy`
    - `vegetables`
    - `fruits`
    - `meat`
    - `legumes`
    - `grains`
    - `nuts`
    - `spices`
    - `snacks`
    - `drinks`
    - `frozen`
    - `breakfast` (New!)
    - `other`
  - [ ] **Fuzzy Matching:** Use string similarity algorithms for new/unknown tags to guess the closest category.

## 2. API Optimization
- [ ] **Batch Processing Endpoint:**
  - [ ] Create a `/bulk-scan` endpoint that accepts a list of barcodes.
  - [ ] Return results for all items in a single response, reducing network round-trips.
  - [ ] Handle partial failures (e.g., 8 items found, 2 not found) gracefully.

## 3. Data Enrichment
- [ ] **Image Proxy/Caching:** Cache OpenFoodFacts images on our own CDN/Firebase Storage to improve loading speed and reliability.
- [ ] **Localized Names:** Prioritize Turkish names (`product_name_tr`) and fallback to English intelligently.

## 4. Maintenance
- [ ] **Monitoring:** Set up alerts for "Product Not Found" rates to identify popular missing items.
- [ ] **Database Cleanup:** Periodically normalize existing user pantry items to match the new category schema.
