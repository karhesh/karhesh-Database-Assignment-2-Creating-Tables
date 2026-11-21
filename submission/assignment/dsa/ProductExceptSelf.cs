public class Solution
{
    // 5.1. Time O(n). Extra space O(n) for the prefix and suffix arrays.
    public int[] ProductExceptSelfWithPrefixAndSuffix(int[] nums)
    {
        int length = nums.Length;
        int[] prefix = new int[length];
        int[] suffix = new int[length];
        int[] answer = new int[length];

        prefix[0] = 1;
        for (int i = 1; i < length; i++)
        {
            prefix[i] = prefix[i - 1] * nums[i - 1];
        }

        suffix[length - 1] = 1;
        for (int i = length - 2; i >= 0; i--)
        {
            suffix[i] = suffix[i + 1] * nums[i + 1];
        }

        for (int i = 0; i < length; i++)
        {
            answer[i] = prefix[i] * suffix[i];
        }

        return answer;
    }

    // 5.2. Time O(n). Extra space O(1), excluding the output array.
    public int[] ProductExceptSelf(int[] nums)
    {
        int length = nums.Length;
        int[] answer = new int[length];

        answer[0] = 1;
        for (int i = 1; i < length; i++)
        {
            answer[i] = answer[i - 1] * nums[i - 1];
        }

        int rightProduct = 1;
        for (int i = length - 1; i >= 0; i--)
        {
            answer[i] *= rightProduct;
            rightProduct *= nums[i];
        }

        return answer;
    }
}
