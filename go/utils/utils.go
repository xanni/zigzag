package utils

import (
	"regexp"
	"strings"
	"unicode/utf8"
)

// ReverseSign reverses the sign of a given dimension string.
// For example, "+d.1" becomes "-d.1" and "-d.foo" becomes "+d.foo".
// If the string does not start with "+" or "-", it's returned unchanged.
func ReverseSign(dim string) string {
	if len(dim) == 0 {
		return ""
	}
	switch dim[0] {
	case '+':
		return "-" + dim[1:]
	case '-':
		return "+" + dim[1:]
	default:
		return dim // Or handle as an error, depending on expected input
	}
}

// WordBreak returns a string up to the first line break or the end of the
// last word that finishes before the given character position (limit).
// The limit is based on the number of characters (runes), not bytes.
func WordBreak(s string, limit int) string {
	if limit <= 0 {
		return ""
	}
	if utf8.RuneCountInString(s) <= limit { // If string is within limit, no need to truncate early
		// Still need to check for newline
		if newlineIndex := strings.Index(s, "\n"); newlineIndex != -1 {
			return s[:newlineIndex] + " "
		}
		return s // Return original string if no newline and within limit
	}

	// Truncate string to the character limit carefully, respecting UTF-8
	var truncatedS strings.Builder
	runeCount := 0
	for _, r := range s {
		if runeCount >= limit {
			break
		}
		truncatedS.WriteRune(r)
		runeCount++
	}
	sub := truncatedS.String()

	// Check for newline in the (potentially) truncated substring
	if newlineIndex := strings.Index(sub, "\n"); newlineIndex != -1 {
		return sub[:newlineIndex] + " "
	}

	// If the original string was actually truncated (i.e. length of sub is 'limit' runes)
	// and no newline was found, try to break at the last word.
	// The Perl code's condition `length eq $_[1]` implies that the substring operation
	// did not shorten the string due to a newline, but rather it was truncated at $_[1] characters.
	// This means we only apply the word break logic if no newline was found before the limit.
	if runeCount == limit { // Check if truncation actually occurred at the 'limit'
		// Regex to find the last word: sequence of non-whitespace chars (\S+)
		// preceded by whitespace (\s+)
		// We want everything *before* that last whitespace.
		// Example: "word1 word2 word3", limit might be middle of word2 or word3.
		// Perl: /^(.+)\s+\S*$/ - captures content before last whitespace and non-whitespace sequence
		// Go equivalent: find last space, then confirm there's a non-space char after it.
		lastSpaceIndex := -1
		foundNonSpaceAfterLastSpace := false

		// Iterate runes backwards to find the last space within the substring 'sub'
		runes := []rune(sub)
		for i := len(runes) - 1; i >= 0; i-- {
			if strings.IsSpace(runes[i]) {
				// Check if there's any non-space character after this space
				if i+1 < len(runes) {
					for j := i + 1; j < len(runes); j++ {
						if !strings.IsSpace(runes[j]) {
							foundNonSpaceAfterLastSpace = true
							break
						}
					}
				}
				if foundNonSpaceAfterLastSpace {
					lastSpaceIndex = i
					break
				}
			}
		}

		if lastSpaceIndex != -1 {
			return string(runes[:lastSpaceIndex])
		}
	}

	// If no newline and no suitable word boundary found, return the substring truncated at limit.
	return sub
}

// WordBreakOriginalPerlRegex is a more direct translation of the Perl regex logic for wordbreak.
// It might behave more closely to the original Perl for the second condition.
func WordBreakOriginalPerlRegex(s string, limit int) string {
	if limit <= 0 {
		return ""
	}

	// Truncate string to the character limit
	var subBuilder strings.Builder
	charCount := 0
	for _, r := range s {
		if charCount >= limit {
			break
		}
		subBuilder.WriteRune(r)
		charCount++
	}
	sub := subBuilder.String()

	// Check for newline: /^(.*)\n/
	newlineRegex := regexp.MustCompile(`^(.*)\n`)
	matches := newlineRegex.FindStringSubmatch(sub)
	if len(matches) > 1 {
		return matches[1] + " "
	}

	// Check for word break: /^(.+)\s+\S*$/
	// This regex means: capture group 1 (.+) followed by one or more whitespace (\s+)
	// and then zero or more non-whitespace characters (\S*$) at the end of the string.
	// This is applied *if* the length of `sub` is equal to the original `limit`
	// (meaning, the substr in Perl didn't stop early due to a newline).
	if charCount == limit { // Only if the string was potentially truncated by limit
		wordBreakRegex := regexp.MustCompile(`^(.+)\s+\S*$`)
		matches = wordBreakRegex.FindStringSubmatch(sub)
		if len(matches) > 1 {
			return matches[1]
		}
	}
	return sub
}
