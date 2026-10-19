# Farah API Contract — Authentication Endpoints

**Base URL:** `https://farah-production.up.railway.app/api`  
**Auth scheme:** Laravel Sanctum — `Authorization: Bearer <token>`  
**Probed:** 2026-08-23

> **Legend**
> - ✅ Confirmed — response body captured from a live call
> - ⚠️ Partial — status code confirmed, body shape not observed
> - ❓ Unknown — could not be reached during probing (see note below)

> **Probe blocker:** The backend's SMTP transport (`smtp.gmail.com:587`) times out
> on the Render free tier. Every `/register` call throws a 500 *after* writing the
> user row but *before* returning the 201, so no verification email is ever sent.
> Because no account can be verified, `/login` never returns 200 and all
> token-gated endpoints are unreachable. The shapes for those responses are
> **unknown and must be confirmed by the backend team.**

---

## Shared error envelope ✅

All non-2xx responses observed follow this shape:

```json
{
  "icon": "error",
  "title": "Human-readable message (Arabic or English)",
  "errors": {
    "field_name": ["Validation message 1", "..."]
  }
}
```

- `icon` — always `"error"` on failure; assumed `"success"` on 2xx (unconfirmed)
- `title` — top-level summary shown to the user
- `errors` — present on **422 only**; keys are field names, values are arrays of strings

---

## POST /register

**Auth required:** No  
**Content-Type:** `application/json`

### Request body

| Field | Type | Required | Notes |
|---|---|---|---|
| `name` | string | yes | |
| `email` | string | yes | must be unique |
| `password` | string | yes | |
| `password_confirmation` | string | yes | must match `password` |
| `user_type` | string | no | `"customer"` or `"provider"` |
| `phone` | string | no | |
| `city_id` | integer | no | |

### Responses

#### 201 Created ❓ UNKNOWN
Account is created but the SMTP call crashes before the response is returned
(see probe blocker above). The 201 body has **never been observed**.

```
// Backend team: please fill in the actual 201 body here.
// Questions:
//   - Does it return a token? (spec says no, but confirm)
//   - Does it return the user object?
//   - What is the top-level key structure?
```

#### 422 Unprocessable Entity ✅ Confirmed

Triggered when email is already registered:

```json
{
  "icon": "error",
  "title": "هذا البريد الإلكتروني مستخدم بالفعل",
  "errors": {
    "email": ["هذا البريد الإلكتروني مستخدم بالفعل"]
  }
}
```

Triggered when required fields fail validation (e.g. invalid email format, missing password):

```json
{
  "icon": "error",
  "title": "الرجاء إدخال بريد إلكتروني صالح",
  "errors": {
    "email": ["الرجاء إدخال بريد إلكتروني صالح"],
    "password": ["The password field is required."]
  }
}
```

> Note: some `title` and `errors` strings are Arabic, others are English.
> The backend team should standardise this.

---

## POST /login

**Auth required:** No  
**Content-Type:** `application/json`

### Request body

| Field | Type | Required |
|---|---|---|
| `email` | string | yes |
| `password` | string | yes |

### Responses

#### 200 OK ❓ UNKNOWN

```
// Backend team: please provide the actual 200 body.
// Questions:
//   - What key holds the bearer token? ("token"? "access_token"? "data.token"?)
//   - Is the user object nested under "user", "data", or flat at the root?
//   - What fields does the user object contain?
//     (id, name, email, phone, user_type, email_verified_at, avatar, city_id, …?)
//   - Is email_verified_at a timestamp, boolean, or null when unverified?
//   - Does the response include token_type or expires_in?
```

#### 401 Unauthorized ✅ Confirmed

Triggered by wrong email/password combination:

```json
{
  "icon": "error",
  "title": "The email or password is incorrect."
}
```

#### 403 Forbidden ✅ Confirmed

Triggered when the account exists but email is not verified:

```json
{
  "icon": "error",
  "title": "Please verify your email before logging in."
}
```

#### 422 Unprocessable Entity ✅ Confirmed

Triggered by invalid field values (e.g. malformed email, empty password):

```json
{
  "icon": "error",
  "title": "الرجاء إدخال بريد إلكتروني صالح",
  "errors": {
    "email": ["الرجاء إدخال بريد إلكتروني صالح"],
    "password": ["The password field is required."]
  }
}
```

---

## POST /logout

**Auth required:** Yes — `Authorization: Bearer <token>`

### Request body
None.

### Responses

#### 200 OK ❓ UNKNOWN
#### 400 Bad Request ⚠️ Status confirmed, body not observed

---

## POST /resend-verification-email

**Auth required:** No  
**Content-Type:** `application/json`

### Request body

| Field | Type | Required |
|---|---|---|
| `email` | string | yes |

### Responses

#### 200 OK ❓ UNKNOWN
#### 400 Bad Request ⚠️ Status confirmed (account already verified), body not observed
#### 422 Unprocessable Entity ⚠️ Status confirmed (email not registered), body not observed

---

## GET /profile

**Auth required:** Yes — `Authorization: Bearer <token>`

### Responses

#### 200 OK ❓ UNKNOWN

```
// Backend team: please provide the actual 200 body.
// Questions (same as login 200 — they likely return the same user shape):
//   - Top-level key wrapping the user? ("user"? "data"? flat?)
//   - Full list of user fields returned
//   - Is avatar a URL string or null?
//   - What does city look like — id integer, or nested object {id, name}?
```

#### 401 Unauthorized ⚠️ Status confirmed, body not observed

---

## POST /profile/update

**Auth required:** Yes — `Authorization: Bearer <token>`  
**Content-Type:** `multipart/form-data`

### Request body

| Field | Type | Required | Notes |
|---|---|---|---|
| `name` | string | no | |
| `phone` | string | no | |
| `city_id` | integer | no | |
| `avatar` | binary file | no | image upload |

### Responses

#### 200 OK ❓ UNKNOWN
#### 422 Unprocessable Entity ⚠️ Status confirmed, body not observed

---

## POST /change-password

**Auth required:** Yes — `Authorization: Bearer <token>`  
**Content-Type:** `application/json`

### Request body

| Field | Type | Required |
|---|---|---|
| `current_password` | string | yes |
| `new_password` | string | yes |
| `new_password_confirmation` | string | yes |

### Responses

#### 200 OK ❓ UNKNOWN
#### 403 Forbidden ⚠️ Status confirmed (wrong current password), body not observed
#### 422 Unprocessable Entity ⚠️ Status confirmed, body not observed

---

## POST /forgot-password

**Auth required:** No  
**Content-Type:** `application/json`

### Request body

| Field | Type | Required |
|---|---|---|
| `email` | string | yes |

### Responses

#### 200 OK ❓ UNKNOWN
#### 422 Unprocessable Entity ⚠️ Status confirmed (email not found), body not observed

---

## POST /reset-password

**Auth required:** No  
**Content-Type:** `application/json`

### Request body

| Field | Type | Required | Notes |
|---|---|---|---|
| `token` | string | yes | from the reset email link |
| `email` | string | yes | |
| `password` | string | yes | |
| `password_confirmation` | string | yes | |

### Responses

#### 200 OK ❓ UNKNOWN
#### 422 Unprocessable Entity ⚠️ Status confirmed (invalid token or mismatch), body not observed

---

## DELETE /account

**Auth required:** Yes — `Authorization: Bearer <token>`

### Request body
None.

### Responses

#### 200 OK ❓ UNKNOWN

---

## Open questions for the backend team

1. **SMTP is broken on Render** — `smtp.gmail.com:587` times out. No verification emails
   are delivered. This blocks the entire auth flow for new users in the current
   deployment. Is there a queue worker that should be handling mail async?

2. **Login 200 body** — what is the exact JSON returned on successful login?

3. **Token key name** — `"token"`, `"access_token"`, or something else?

4. **User object shape** — full list of fields, types, and whether city is a scalar
   or a nested object.

5. **email_verified_at** — timestamp string, boolean, or absent when null?

6. **Avatar field** — full URL or relative path?

7. **Consistent language** — some error messages are Arabic, some English. Which
   language should field-level `errors` be in?

8. **Register 201** — does it return anything useful, or just `{"message": "..."}`?
