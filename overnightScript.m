function overnightScript()

ab1 = [1.4,  6,  4];
ab2 = [  3,  6, 10];
ab3 = [  4,  6, 10];
ab4 = [ 2.2, 6, 4];
at1 = [  3.5,  6, 10];
pb1 = [  2.2, 6, 10];


dateCode = '141114';
prelimSortDirectory(dateCode,'00[2,3,4]_*.mat',2, ab3);
prelimSortDirectory(dateCode,'00[5,6]_*.mat',4, ab1);

dateCode = '141210';
prelimSortDirectory(dateCode,'00[1]_*.mat',2, ab2);

dateCode = '141009';
prelimSortDirectory(dateCode,'00[1,2,3,8]_*.mat',4, ab1);
prelimSortDirectory(dateCode,'011_*.mat',4, ab1);
dateCode = '141009';
prelimSortDirectory(dateCode,'00[4,5,7]_*.mat',2, ab3);
prelimSortDirectory(dateCode,'010_*.mat',2,ab3);

dateCode = '141104';
prelimSortDirectory(dateCode,'00[3,4,5]_*.mat',4, ab1);
dateCode = '141104';
prelimSortDirectory(dateCode,'00[6,7]_*.mat',2, ab4);

dateCode = '140618';
prelimSortDirectory(dateCode,'00[1,2,3,4]_*.mat',4, ab1);
dateCode = '140808';
prelimSortDirectory(dateCode,'00[3]_*.mat',4, ab1);

dateCode = '141002';
prelimSortDirectory(dateCode,'00[5]_*.mat',2, ab4);

dateCode = '141107';
prelimSortDirectory(dateCode,'00[2,3,4]_*.mat',4, ab1);
prelimSortDirectory(dateCode,'00[5,6]_*.mat',2, ab4);

dateCode = '141103';
prelimSortDirectory(dateCode,'00[1,2,3]_*.mat',4, ab1);
prelimSortDirectory(dateCode,'010_*.mat',4, ab1);
prelimSortDirectory(dateCode,'011_*.mat',4, ab1);
prelimSortDirectory(dateCode,'012_*.mat',4, ab1);
prelimSortDirectory(dateCode,'00[4,5,7,9]_*.mat',2, ab2);
prelimSortDirectory(dateCode,'013_*.mat',2, ab2);
prelimSortDirectory(dateCode,'014_*.mat',2, ab2);
prelimSortDirectory(dateCode,'015_*.mat',2, ab2);

dateCode = '141108';
prelimSortDirectory(dateCode,'00[5,8,9]_*.mat',4, ab1);
prelimSortDirectory(dateCode,'011_*.mat',4, ab1);
prelimSortDirectory(dateCode,'012_*.mat',2, ab2);
prelimSortDirectory(dateCode,'013_*.mat',2, ab2);
prelimSortDirectory(dateCode,'014_*.mat',2, ab2);

dateCode = '150320';
prelimSortDirectory(dateCode,'00[7]_*.mat',4, ab1);
prelimSortDirectory(dateCode,'00[2,6]_*.mat',2, ab3);







