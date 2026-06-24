# SAP Fiori Input Masks with Regular Expression Validation

Hello Everyone! 👋

A new CDS annotation, @UI.inputMask, allows you to define input masks and regular expression validations directly in SAP Fiori applications.

We often come across scenarios where a field value must follow a specific format, such as SWIFT codes, reference numbers, or other business-specific identifiers. Traditionally, this requires custom validation logic to validate prefixes, character types, and overall patterns.

With @UI.inputMask, these requirements can be handled directly at the UI level, improving user guidance and reducing the need for custom validation logic.

> **Note:**
>
> * As of now, `@UI.inputMask` is available in the latest verison of **SAP S/4HANA Public Cloud** and the **ABAP Environment (Steampunk/BTP ABAP Environment)**.
> * The mask is applied only at the **UI layer** for input guidance, validation, and display purposes.
> * The underlying data is stored and transferred **without the mask formatting characters**. The mask does not change the actual value persisted in the database.
> * As of now, dynamic masks are not supported; the mask must be defined statically in the annotation.

## Example 1: Standard Mask

```abap
@UI.inputMask: {
  mask: 'AAAA-AA-XX-XXX',
  placeholderSymbol: '_',
  rules: [
    { maskSymbol: 'X', regularExpression: '[a-zA-Z0-9]' },
    { maskSymbol: 'A', regularExpression: '[a-zA-Z]' }
  ]
}
fieldname;
```

### Result

```text
____-__-__-___
```

### Valid Input

```text
ABCD-EF-A1-B2C
```

Where:

* `A` accepts only alphabetic characters (`A-Z`, `a-z`)
* `X` accepts alphanumeric characters (`A-Z`, `a-z`, `0-9`)

---

## Example 2: Fixed Prefix

```abap
@UI.inputMask: {
  mask: 'CONST-AA-XX-XXX',
  placeholderSymbol: '_',
  rules: [
    { maskSymbol: 'X', regularExpression: '[a-zA-Z0-9]' },
    { maskSymbol: 'A', regularExpression: '[a-zA-Z]' }
  ]
}
fieldname;
```

### Result

```text
CONST-__-__-___
```

### Valid Input

```text
CONST-AB-C1-D2E
```

Since `CONST` is not part of any rule, it is treated as a fixed literal value and displayed automatically.

---

## Example 3: Escaping a Mask Symbol

```abap
@UI.inputMask: {
  mask: 'C^AR-AA-XX-XXX',
  placeholderSymbol: '_',
  rules: [
    { maskSymbol: 'X', regularExpression: '[a-zA-Z0-9]' },
    { maskSymbol: 'A', regularExpression: '[a-zA-Z]' }
  ]
}
fieldname;
```

### Result

```text
CAR-__-__-___
```

### Valid Input

```text
CAR-AB-C1-D2E
```

In this example, `A` is defined as a mask symbol. By using the escape character (`^`), the `A` in `CAR` is treated as a literal character rather than a mask placeholder.

---
