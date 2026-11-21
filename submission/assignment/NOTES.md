## Task 5 hand trace

I started with `[1, 2, 3, 4]`. The prefix is the product of the numbers before the current index, and the suffix is the product of the numbers after it. I used `1` whenever a side was empty.

- Index 0, value 1. Prefix is `1`. Suffix is `2 * 3 * 4 = 24`. This gives `24`.
- Index 1, value 2. Prefix is `1`. Suffix is `3 * 4 = 12`. This gives `12`.
- Index 2, value 3. Prefix is `1 * 2 = 2`. Suffix is `4`. This gives `8`.
- Index 3, value 4. Prefix is `1 * 2 * 3 = 6`. Suffix is `1`. This gives `6`.

My final array is `[24, 12, 8, 6]`.
