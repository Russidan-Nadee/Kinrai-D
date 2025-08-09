export class AnalyticsReportDto {
  user_stats: {
    total_favorites: number;
    total_dislikes: number;
    total_ratings: number;
    average_rating_given: number;
    dietary_restrictions_count: number;
    most_liked_category?: string;
    most_liked_meal_time?: string;
  };
  
  activity_timeline: Array<{
    date: string;
    favorites_added: number;
    ratings_given: number;
    dislikes_added: number;
  }>;
  
  preferences_insight: {
    top_categories: Array<{
      category: string;
      interaction_count: number;
    }>;
    meal_time_distribution: {
      breakfast: number;
      lunch: number;
      dinner: number;
      snack: number;
    };
    protein_preferences: Array<{
      protein_type: string;
      preference_score: number;
    }>;
  };
}