class MarkersDataObj{
  bool markerTopLeft = true;
  bool markerTopCenter = true;
  bool markerTopRight = true;
  bool markerMiddleLeft = true;
  bool markerCenter = true;
  bool markerMiddleRight = true;
  bool markerBottomLeft = true;
  bool markerBottomCenter = true;
  bool markerBottomRight = true;

  MarkersDataObj(){
    markerTopLeft = true;
    markerTopCenter = true;
    markerTopRight = true;
    markerMiddleLeft = true;
    markerCenter = true;
    markerMiddleRight = true;
    markerBottomLeft = true;
    markerBottomCenter = true;
    markerBottomRight = true;
  }

  MarkersDataObj.fromJson(Map<String, dynamic> json)
      : markerTopLeft = json['markerTopLeft'],
        markerTopCenter = json['markerTopCenter'],
        markerTopRight = json['markerTopRight'],
        markerMiddleLeft = json['markerMiddleLeft'],
        markerCenter = json['markerCenter'],
        markerMiddleRight = json['markerMiddleRight'],
        markerBottomLeft = json['markerBottomLeft'],
        markerBottomCenter = json['markerBottomCenter'],
        markerBottomRight = json['markerBottomRight']
  ;

  Map<String, dynamic> toJson() => {
    'markerTopLeft': markerTopLeft,
    'markerTopCenter': markerTopCenter,
    'markerTopRight': markerTopRight,
    'markerMiddleLeft': markerMiddleLeft,
    'markerCenter': markerCenter,
    'markerMiddleRight': markerMiddleRight,
    'markerBottomLeft': markerBottomLeft,
    'markerBottomCenter': markerBottomCenter,
    'markerBottomRight': markerBottomRight,
  };

  @override
  String toString() {
    return 'MarkersDataObj{markerTopLeft: $markerTopLeft, markerTopCenter: $markerTopCenter, markerTopRight: $markerTopRight, markerMiddleLeft: $markerMiddleLeft, markerCenter: $markerCenter, markerMiddleRight: $markerMiddleRight, markerBottomLeft: $markerBottomLeft, markerBottomCenter: $markerBottomCenter, markerBottomRight: $markerBottomRight}';
  }


}