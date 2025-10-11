# API Documentation

## Item List

Retrieves a list of items.

### Endpoint

`GET /api/item-list`

### Controller Method

[`App\Http\Controllers\PatientController::ItemList()`](app/Http/Controllers/PatientController.php:200)

### Request

This endpoint accepts the following query parameters:

- `search` (optional): A string to filter items by their name.

### Response

Returns a JSON array of item objects, limited to 10 results.

```json
[
  {
    "ItemID": 1,
    "ItemName": "Item 1",
    "ItemDescription": "Description for Item 1"
  },
  {
    "ItemID": 2,
    "ItemName": "Item 2",
    "ItemDescription": "Description for Item 2"
  }
]
```

## Invention List

Retrieves a list of inventions (tests).

### Endpoint

`GET /api/invention-list`

### Controller Method

[`App\Http\Controllers\PatientController::inventionList()`](app/Http/Controllers/PatientController.php:213)

### Request

This endpoint accepts the following query parameters:

- `search` (optional): A string to filter inventions by their name.

### Response

Returns a JSON array of invention objects, limited to 10 results.

```json
[
  {
    "TestID": 1,
    "TestName": "Test 1",
    "TestDescription": "Description for Test 1"
  },
  {
    "TestID": 2,
    "TestName": "Test 2",
    "TestDescription": "Description for Test 2"
  }
]
```

## Advice List

Retrieves a list of advices.

### Endpoint

`GET /api/advice-list`

### Controller Method

[`App\Http\Controllers\PatientController::adviceList()`](app/Http/Controllers/PatientController.php:226)

### Request

This endpoint accepts the following query parameters:

- `search` (optional): A string to filter advices by their name.

### Response

Returns a JSON array of advice objects, limited to 10 results.

```json
[
  {
    "AdvID": 1,
    "AdvName": "Advice 1",
    "AdvDescription": "Description for Advice 1"
  },
  {
    "AdvID": 2,
    "AdvName": "Advice 2",
    "AdvDescription": "Description for Advice 2"
  }
]
```

## Content List

Retrieves a list of content.

### Endpoint

`GET /api/content-list`

### Controller Method

[`App\Http\Controllers\PatientController::ContentList()`](app/Http/Controllers/PatientController.php:239)

### Request

This endpoint accepts the following query parameters:

- `search` (optional): A string to filter content by their name.

### Response

Returns a JSON array of content objects, limited to 10 results.

```json
[
  {
    "ContentID": 1,
    "ContentName": "Content 1",
    "ContentText": "Text for Content 1"
  },
  {
    "ContentID": 2,
    "ContentName": "Content 2",
    "ContentText": "Text for Content 2"
  }
]
```
