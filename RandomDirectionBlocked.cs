 private int RandomDirectionBlocked(List<int> block)
    {
        if (block.Count == 0)
        {
            return RandomDirection();
        }

        List<int> directions = new List<int>
        {
            0, 1, 2, 3
        };

        foreach (int i in block)
        {
            if (i == -1)
            {
                return RandomDirection();
            }
            else
            {
                directions.Remove(i);
            }
        }

        float rand = Random.value;
        rand = Math.Min(rand, 0.99999f);

        return directions[(int) (rand * ( 4 - block.Count))];
    }