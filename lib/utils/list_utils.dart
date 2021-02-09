class ListUtils {
  
  static List multisort(List list, List<bool> criteria, List<String> properties) {

    if(list.length == 0 || criteria.length == 0 || properties.length == 0) {
      return list;
    }

    if(criteria.length != properties.length) {
      throw ArgumentError('Criteria length is not equal to properties length');
    }

    int compare(int i, dynamic a, dynamic b) {     
      if (a.get(properties[i]).compareTo(b.get(properties[i])) == 0)      
        return 0;
      else if (a.get(properties[i]).compareTo(b.get(properties[i])) == 1)
        return criteria[i] ? 1 : -1;
      else
        return criteria[i] ? -1 : 1;
    }

    list.sort((a, b) {
      int i = 0;
      int result = 0;
      while(i < properties.length) {
        result = compare(i, a, b);
        if(result != 0) break;
        i++;
      }
      return result;
    });

    return list;
  }

}