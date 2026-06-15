---
name: spec-tester
description: Test API specifications, validation rules, and DTO contracts. Use when verifying API endpoints, request/response validation, or testing business logic specs.
---

# Spec Tester

Test API specifications, validation rules, and DTO contracts in Laravel applications.

## Core Capabilities

1. **API Spec Testing** - Test endpoints against OpenAPI/Swagger specs
2. **DTO Validation Testing** - Verify Spatie DTO rules match expectations
3. **Request Validation Testing** - Test FormRequest/API request validation rules
4. **Response Contract Testing** - Verify API resources return expected structure

## Testing Strategies

### API Endpoint Testing

When testing API endpoints:

1. **Identify the route** - Check `routes/Api/*.php` for route definitions
2. **Extract validation rules** - Read the Request DTO or FormRequest class
3. **Test valid data** - Send requests with valid data, verify 200/201 response
4. **Test invalid data** - Send requests with invalid data, verify 422 response + proper errors
5. **Test edge cases** - Null values, boundary values, unexpected types

### DTO Rule Testing

For Spatie Laravel Data DTOs:

1. **Read the DTO class** - Check `app/DTOs/Requests/*.php`
2. **Extract rules** - Look for `static rules(): array` method or PHP attributes
3. **Test each rule** - Create test cases for required, string, integer, email, etc.
4. **Test custom rules** - If using custom validation rules, test them explicitly

### Resource Testing

For API Resources:

1. **Read the Resource** - Check `app/Http/Resources/Api/*.php`
2. **Verify structure** - Ensure response matches documented structure
3. **Test relationships** - Verify nested resources are properly included
4. **Test conditional fields** - When fields are conditionally added

## Common Test Patterns

### Test API Endpoint

```
1. Read route definition in routes/Api/{Module}/route.php
2. Read the corresponding Request DTO in app/DTOs/Requests/
3. Read the API Controller in app/Http/Controllers/Api/
4. Generate test cases:
   - Valid data test
   - Invalid data tests (each validation rule)
   - Edge cases (null, empty, wrong type)
5. Run tests with: docker exec prosper_app_dev ./vendor/bin/phpunit --filter=TestName
```

### Test DTO Validation

```
1. Read DTO class in app/DTOs/Requests/Create{Name}Dto.php
2. Extract validation rules from static rules() method
3. Create test data for each rule:
   - Required fields: test missing field → expect error
   - String fields: test integer → expect error
   - Email fields: test invalid email → expect error
4. Test via: POST to endpoint with test data
5. Verify response errors match expected validation messages
```

### Test Closing-Specific Features

For the Prosper project's closing features:

```
1. Test brokerage validation (max % based on insurance type)
2. Test team_id auto-fill on closings
3. Test policy_numbers array handling
4. Test file validation (at least one closing_file required)
5. Test DNCN creation on approval
```

## Test Commands

### Run Specific Test
```bash
docker exec prosper_app_dev ./vendor/bin/phpunit --filter=test_method_name
```

### Run Test Suite
```bash
docker exec prosper_app_dev ./vendor/bin/phpunit tests/Feature/Api/
```

### Run with Coverage
```bash
docker exec prosper_app_dev ./vendor/bin/phpunit --coverage-html coverage/
```

## Example: Test Brokerage Validation

Given the brokerage percentage validation in `AGENTS.md`:

```php
// Test case
public function test_brokerage_validation_for_fire_risk(): void
{
    // Setup: Create insurance type with risk_category.code = 'fr'
    // Test: Send closing data with brokerage = 20% (should fail, max 15%)
    // Assert: 422 response with proper validation error
}
```

## Test Checklist

Before delivering API changes:

- [ ] All DTO validation rules tested
- [ ] All API endpoints return correct status codes
- [ ] Response structure matches Resource definition
- [ ] Error responses include helpful messages
- [ ] Edge cases handled (null, empty, wrong types)
- [ ] Authentication/authorization working
- [ ] Team-based gating verified (for closings/dncns)

## Quick Test Template

```php
<?php

namespace Tests\Feature\Api;

use Tests\TestCase;

class {Resource}Test extends TestCase
{
    public function test_store_with_valid_data(): void
    {
        $data = [
            // valid test data
        ];
        
        $response = $this->postJson(route('module.resource.store'), $data);
        
        $response->assertStatus(201);
        $response->assertJsonStructure([
            // expected response structure
        ]);
    }
    
    public function test_store_with_invalid_data(): void
    {
        $data = [
            // invalid test data
        ];
        
        $response = $this->postJson(route('module.resource.store'), $data);
        
        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['field_name']);
    }
}
```
