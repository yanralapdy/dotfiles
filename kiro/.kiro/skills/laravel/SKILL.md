---
name: laravel-best-practices
description: Laravel conventions, patterns, and best practices for this project. Use when writing or reviewing Laravel PHP code.
---

# Laravel Best Practices

## Structure
- Controllers are thin — delegate to Service classes
- Services contain business logic; they are injected via constructor
- Repositories handle data access; return Eloquent models or DTOs
- Form Requests validate input; never validate in controllers
- API Resources transform Eloquent models for responses

## Eloquent
- Always eager-load relationships to avoid N+1: `->with(['relation'])`
- Use `select()` to limit columns on large tables
- Scope complex queries into named scopes on the model
- Use database transactions for multi-step writes: `DB::transaction(fn() => ...)`

## API Responses
```php
// Success
return new UserResource($user);                    // 200
return new UserResource($user)->response()->setStatusCode(201); // 201
return response()->noContent();                    // 204

// Error — use abort() or custom exceptions
abort(404, 'User not found');
abort(422, 'Validation failed');
```

## Validation
```php
// Form Request
public function rules(): array {
    return [
        'email' => ['required', 'email', 'unique:users,email'],
        'name'  => ['required', 'string', 'max:255'],
    ];
}
```

## Testing
- Feature tests for all API endpoints using `RefreshDatabase`
- Assert HTTP status, response structure, and database state
```php
$this->postJson('/api/users', $data)
     ->assertCreated()
     ->assertJsonPath('data.email', $data['email']);
$this->assertDatabaseHas('users', ['email' => $data['email']]);
```

## Common Pitfalls
- Never use `$request->all()` — use `$request->validated()` or `$request->safe()`
- Never store secrets in code — use `.env` and `config()`
- Never call `->get()` inside a loop — batch queries outside
