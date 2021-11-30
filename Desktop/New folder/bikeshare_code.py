import time
import pandas as pd
import numpy as np
import calendar

CITY_DATA = { 'chicago': 'chicago.csv',
              'new york city': 'new_york_city.csv',
              'washington': 'washington.csv' }

def get_filters():
    """
    Asks user to specify a city, month, and day to analyze.

    Returns:
        (str) city - name of the city to analyze
        (str) month - name of the month to filter by, or "all" to apply no month filter
        (str) day - name of the day of week to filter by, or "all" to apply no day filter
    """
    print('Hello! Let\'s explore some US bikeshare data!')

    while True:
        city = input('\nWhat city would like to obtain descriptive statistics about?').lower()
        if city in CITY_DATA:
            break
        else:
            print('Details for this city is unavailable, please enter another city')

    while True:
        months = ['all', 'january', 'february', 'march', 'april', 'may', 'june']
        month = input('What month would you like to inquire about?').lower()
        if month in months:
            break
        else:
            print('Details for this month is unavailable, please enter another month')

    while True:
        days = ['all', 'sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']
        day = input('What day would like to inquire about?').lower()
        if day in days:
            break
        else:
            print('Details for this day is unavailable, please enter another day')

    print('-'*40)
    return city, month, day

def load_data(city, month, day):
    """
    Loads data for the specified city and filters by month and day if applicable.

    Args:
        (str) city - name of the city to analyze
        (str) month - name of the month to filter by, or "all" to apply no month filter
        (str) day - name of the day of week to filter by, or "all" to apply no day filter
    Returns:
        df - Pandas DataFrame containing city data filtered by month and day
    """
    df = pd.read_csv(CITY_DATA[city])

    # convert the Start Time column to datetime
    df['Start Time'] = pd.to_datetime(df['Start Time'])

    # extract month and day of week from Start Time to create new columns
    df['month'] = df['Start Time'].dt.month
    df['day_of_week'] = df['Start Time'].dt.dayofweek
    df['start_hour'] = df['Start Time'].dt.hour

    # filter by month if applicable
    if month != 'all':
        # use the index of the months list to get the corresponding int
        months = ['january', 'february', 'march', 'april', 'may', 'june']
        month = months.index(month) + 1

        # filter by month to create the new dataframe
        df = df[df['month'] == month]

    # filter by day of week if applicable
    if day != 'all':
        # filter by day of week to create the new dataframe
        days = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']
        day = days.index(day)

        # filter by day to create the new dataframe
        df = df[df['day_of_week'] == day]

    return df

def data_preview(df):
    '''Displays 5 lines of data on user's request'''

    preview = input('Would you like to preview the first 5 lines of your dataset of choice? Please type in Yes or No!\n').lower()
    counter = 0

    while preview == 'yes':
        counter += 5
        print(df.iloc[counter-5: counter, :])
        preview = input('Do you want to preview the next 5 lines of the dataset? Please type in Yes or No!\n').lower()

def time_stats(df):
    """Displays statistics on the most frequent times of travel.
       Time can be observed in units of seconds, minutes and days"""

    print('\nCalculating The Most Frequent Times of Travel...\n')
    start_time = time.time()

    freq_month = df['month'].value_counts().idxmax()
    month_name = calendar.month_name[freq_month]
    print('The most frequent month is: {}'.format(month_name))

    freq_dow = df['day_of_week'].value_counts().idxmax()
    day_name = calendar.day_name[freq_dow]
    print('The most frequent day of the week is: {}'.format(day_name))

    print('The most frequent start hour is: {}'.format(df['start_hour'].value_counts().idxmax()))

    print("\nThis took %s seconds." % (time.time() - start_time))
    print('-'*40)

def station_stats(df):
    """Displays statistics on the most popular stations and trip."""

    print('\nCalculating The Most Popular Stations and Trip...\n')
    start_time = time.time()

    print('The most commonly used start station is:\n{}\nThe total number of times it is used is:\n{}\n'.format(df['Start Station'].value_counts().idxmax(), df['Start Station'].value_counts()[0]))

    print('The most commonly used end station is:\n{}\nThe total number of times it is used is:\n{}\n'.format(df['End Station'].value_counts().idxmax(), df['End Station'].value_counts()[0]))

    print("The most frequent combination of start station and end station is: \n{}".format(df.groupby(['Start Station', 'End Station']).size().sort_values(ascending=False).head(1)))

    print("\nThis took %s seconds." % (time.time() - start_time))
    print('-'*40)

def trip_duration_stats(df):
    """Displays statistics on the total and average trip duration.
       Time can be observed in seconds, minutes and days."""

    print('\nCalculating Trip Duration...\n')
    start_time = time.time()

    tot_trav_time_secs = df['Trip Duration'].sum()
    tot_trav_time_mins = tot_trav_time_secs/60
    tot_trav_time_days = tot_trav_time_mins/1440
    print('The total travel time in seconds is: \n{}\nIn minutes it is: \n{}\nIn days it is\n{}\n'.format(tot_trav_time_secs, tot_trav_time_mins, tot_trav_time_days))

    mean_trav_time_secs = df['Trip Duration'].mean()
    mean_trav_time_mins = mean_trav_time_secs/60
    mean_trav_time_days = mean_trav_time_mins/1440
    print('The mean travel time in seconds is \n{}\nIn minutes it is: \n{}\nIn days it is\n{}\n'.format(mean_trav_time_secs, mean_trav_time_mins, mean_trav_time_days))

    print("\nThis took %s seconds." % (time.time() - start_time))
    print('-'*40)

def user_stats(df):
    """Displays statistics on bikeshare users.
       Handles exceptions of no gender and birth year"""

    print('\nCalculating User Stats...\n')
    start_time = time.time()

    print('The total count of different users is: \n{}'.format(df['User Type'].value_counts()))

    if 'Gender' in df.columns:

        print('The total count of different gender is: \n{}'.format(df['Gender'].value_counts()))

        print('The earliest year of birth is: \n{}'.format(df['Birth Year'].min()))

        print('The most recent year of birth is: \n{}'.format(df['Birth Year'].max()))

        print('The most common year of birth is: \n{}'.format(df['Birth Year'].value_counts().idxmax()))
    else:
        print('\nPlease note that this dataset does not hold any data for Gender and Birth Year')
    print("\nThis took %s seconds." % (time.time() - start_time))
    print('-'*40)

def main():
    while True:
        city, month, day = get_filters()
        df = load_data(city, month, day)
        data_preview(df)
        time_stats(df)
        station_stats(df)
        trip_duration_stats(df)
        user_stats(df)

        restart = input('\nWould you like to restart? Enter yes or no.\n')
        if restart.lower() != 'yes':
            break

if __name__ == "__main__":
	main()
