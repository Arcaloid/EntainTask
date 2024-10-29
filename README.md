### Development Environment
- Xcode 15.2
- Deployment target iOS 17
- Swift 5

### Assumptions
- As the API does not guarentee to return at least 5 races for each of the categories, when display only 1 or 2 categories, it may shows less than 5 races
- When the count down of a race reaches -60s, it will be removed from list and uses existing data to fill the list to show up to 5 races
- When the total number of displayed races becomes less than 5, i.e. more than 5 races has started more than 1 min ago. App will automatically calls API again to fetch new data