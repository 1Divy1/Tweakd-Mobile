class UsernameValidator {
  static String? validate(String? value) {
    // Check if the username is null or empty
    if (value == null || value.isEmpty) {
      return 'The username cannot be empty.';
    }

    // Check if the username is too short
    if (value.length < 3) {
      return 'The username must have at least 3 characters.';
    }

    /* RegEx rules:
        ^[a-z]       -> Must begin with a lowercase letter
        [a-z._]*$    -> The following characters can be lowercase letters, dots, or underscores
        \s           -> Check if there are whitespaces in the string
    */
    
    // Check for whitespaces
    if (value.contains(RegExp(r'\s'))) {
      return 'Whitespaces are not allowed. Use underscore (_) or dots (.).';
    }

    // Check if the first character is a lowercase letter
    if (!value.startsWith(RegExp(r'^[a-z]'))) {
      return 'The username must begin with a lowercase letter.';
    }

    // Check for invalid characters
    if (!RegExp(r'^[a-z][a-z._]*$').hasMatch(value)) {
      return 'Only lowercase letters, dots (.), and underscores (_) are allowed.';
    }

    return null; // Null means the input is valid
  }
}
