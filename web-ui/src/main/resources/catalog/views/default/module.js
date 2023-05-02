/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

(function() {

  goog.provide('gn_search_default');




  goog.require('cookie_warning');
  goog.require('gn_mdactions_directive');
  goog.require('gn_related_directive');
  goog.require('gn_search');
  goog.require('gn_gridrelated_directive');
  goog.require('gn_search_default_config');
  goog.require('gn_search_default_directive');

  var module = angular.module('gn_search_default',
      ['gn_search', 'gn_search_default_config',
       'gn_search_default_directive', 'gn_related_directive',
       'cookie_warning', 'gn_mdactions_directive', 'gn_gridrelated_directive']);


  module.controller('gnsSearchPopularController', [
    '$scope', 'gnSearchSettings',
    function($scope, gnSearchSettings) {
      $scope.searchObj = {
        permalink: false,
        internal: true,
        filters: gnSearchSettings.filters,
        params: {
          sortBy: 'popularity',
          from: 1,
          to: 12
        }
      };
    }]);


  module.controller('gnsSearchLatestController', [
    '$scope', 'gnSearchSettings',
    function($scope, gnSearchSettings) {
      $scope.searchObj = {
        permalink: false,
        internal: true,
        filters: gnSearchSettings.filters,
        params: {
          sortBy: 'changeDate',
          from: 1,
          to: 12
        }
      };
    }]);


  module.controller('gnsSearchTopEntriesController', [
    '$scope', 'gnGlobalSettings',
    function($scope, gnGlobalSettings) {
      $scope.resultTemplate = '../../catalog/components/' +
        'search/resultsview/partials/viewtemplates/grid4maps.html';
      $scope.searchObj = {
        permalink: false,
        internal: true,
        filters: {
          'type': 'interactiveMap'
        },
        params: {
          sortBy: 'changeDate',
          from: 1,
          to: 30
        }
      };
    }]);


  module.controller('gnsDefault', [
    '$scope',
    '$location',
    '$filter',
    'suggestService',
    '$http',
    '$translate',
    'gnUtilityService',
    'gnSearchSettings',
    'gnViewerSettings',
    'gnMap',
    'gnMdView',
    'gnMdViewObj',
    'gnWmsQueue',
    'gnSearchLocation',
    'gnOwsContextService',
    'hotkeys',
    'gnGlobalSettings',
    'gnExternalViewer',
    function($scope, $location, $filter,
             suggestService, $http, $translate,
             gnUtilityService, gnSearchSettings, gnViewerSettings,
             gnMap, gnMdView, mdView, gnWmsQueue,
             gnSearchLocation, gnOwsContextService,
             hotkeys, gnGlobalSettings, gnExternalViewer) {

      var viewerMap = gnSearchSettings.viewerMap;
      var searchMap = gnSearchSettings.searchMap;


      var recordMap = gnSearchSettings.recordMap;

      $scope.isArray = angular.isArray;
      $scope.modelOptions = angular.copy(gnGlobalSettings.modelOptions);
      $scope.modelOptionsForm = angular.copy(gnGlobalSettings.modelOptions);
      $scope.isFilterTagsDisplayedInSearch = gnGlobalSettings.gnCfg.mods.search.isFilterTagsDisplayedInSearch;
      $scope.gnWmsQueue = gnWmsQueue;
      $scope.$location = $location;
      $scope.activeTab = '/home';
      $scope.formatter = gnGlobalSettings.gnCfg.mods.search.formatter;
      $scope.listOfResultTemplate = gnGlobalSettings.gnCfg.mods.search.resultViewTpls;
      $scope.resultTemplate = gnSearchSettings.resultTemplate;
      $scope.viewTemplates = gnSearchSettings.resultViewTpls;
      $scope.advandedSearchTemplate = gnSearchSettings.advancedSearchTemplate;
      $scope.facetsSummaryType = gnSearchSettings.facetsSummaryType;
      $scope.facetConfig = gnSearchSettings.facetConfig;
      $scope.facetTabField = gnSearchSettings.facetTabField;
      $scope.location = gnSearchLocation;
      $scope.states = {};
      $scope.visible = true;
      $scope.states.activeItem = $scope.viewTemplates[0].tooltip;
      $scope.fluidLayout = gnGlobalSettings.gnCfg.mods.home.fluidLayout;
      $scope.fluidEditorLayout = gnGlobalSettings.gnCfg.mods.editor.fluidEditorLayout;
      $scope.fluidHeaderLayout = gnGlobalSettings.gnCfg.mods.header.fluidHeaderLayout;
      $scope.showGNName = gnGlobalSettings.gnCfg.mods.header.showGNName;
      $scope.toggleMap = function () {
        $(searchMap.getTargetElement()).toggle();
        $('button.gn-minimap-toggle > i').toggleClass('fa-angle-double-left fa-angle-double-right');
      };
      $scope.changeView = function (index) {
        $scope.states.activeItem = $scope.viewTemplates[index].tooltip;
        $scope.resultTemplate = $scope.viewTemplates[index].tplUrl;        
      };
      hotkeys.bindTo($scope)
        .add({
            combo: 'h',
            description: $translate.instant('hotkeyHome'),
            callback: function(event) {
              $location.path('/home');
            }
          }).add({
            combo: 't',
            description: $translate.instant('hotkeyFocusToSearch'),
            callback: function(event) {
              event.preventDefault();
              var anyField = $('#gn-any-field');
              if (anyField) {
                gnUtilityService.scrollTo();
                $location.path('/search');
                anyField.focus();
              }
            }
          }).add({
            combo: 'enter',
            description: $translate.instant('hotkeySearchTheCatalog'),
            allowIn: 'INPUT',
            callback: function() {
              $location.search('tab=search');
            }
            //}).add({
            //  combo: 'r',
            //  description: $translate.instant('hotkeyResetSearch'),
            //  allowIn: 'INPUT',
            //  callback: function () {
            //    $scope.resetSearch();
            //  }
          }).add({
            combo: 'm',
            description: $translate.instant('hotkeyMap'),
            callback: function(event) {
              $location.path('/map');
            }
          });


      // TODO: Previous record should be stored on the client side
      $scope.mdView = mdView;
      gnMdView.initMdView();

      $scope.getAsArray = function(values){
        if(angular.isArray(values)){
          return values;
        }else{
          return [values];          
        }
      }

      $scope.isHprmLink = function(association){
        var link = association.split('~')[3];
        if(link && link.startsWith('http://rmweb/HPEContentManager/')){
          return true;
        }
        return false;
      }

      $scope.isAvailable = function(item, item1){
        if(item || item1){
          return true;
        }

        return false;
      }

      $scope.toggleAndTriggerSearch = function(){
       var adv_opened = $('#adv-1').hasClass('in');
        if(adv_opened === true){
          $('#adv-1').collapse('toggle');
        }
        $scope.$broadcast('search');        
      }
      $scope.displayKeyword = function(thesaurus, keywords){
        if(thesaurus.toLowerCase() === 'other' && keywords.length <= 0){
          return false;
        }
        return true;
      }
      $scope.getThumbnail = function(image){
    	  return image.toString().split('|')[1];
	  }
      $scope.getKeywordTitle = function(title){
        if(title.toLowerCase().indexOf('theme.anzrc') >= 0){
          title = 'ANZRC Fields Of Research';
        }       
        return title;
      }
      $scope.bboxStr = '';
      $scope.getBoundingBox = function(bbox) {
        $scope.bboxStr = '';
          if(bbox[1]){
            var vals = bbox[1].split('|');
            if(vals[0]){
              $scope.bboxStr += "west longitude : " + parseFloat(vals[0]).toFixed(2) + "<br>" + 
                          "south latitude: " + parseFloat(vals[1]).toFixed(2) + "<br>" + 
                          "east longitude: " + parseFloat(vals[2]).toFixed(2) + "<br>" + 
                          "north latitude: " + parseFloat(vals[3]).toFixed(2);
            }
          }
      }
      $scope.getCitation = function(md){
        if(md){
          var citationUrl = '';
          if(angular.isArray(md.author) && md.author.length > 0){
            citationUrl = md.author.join(', ') + ' ';
          }else{
            if(md.author){
              citationUrl = md.author + ' ';
            }
          }
  
          if(md.publicationDate){
            var date = new Date(md.publicationDate);
            citationUrl += date.getFullYear() + '. ';
          }
          
          citationUrl += md.title + '. ';
  
          if(md.issueIdentification){
            var rec = md.issueIdentification.toLowerCase().includes('rec') ? '' : 'Record ';
            citationUrl = citationUrl + rec + md.issueIdentification + '. ';
          }
  
          citationUrl += 'Geoscience Australia, Canberra. ';
          
          if(md.DOI){
            citationUrl += md.DOI;
          }else if(md.PID){
            citationUrl += md.PID;
          }else{
            var scope = md.type === 'service' ? 'service' : 'dataset';
            citationUrl += "https://pid.geoscience.gov.au/" + scope + "/ga/" + md.eCatId;
          }
          
          return citationUrl;
        }
        
      }

      $scope.goToSearch = function (any) {
        $location.path('/search').search({'title_OR_altTitle_OR_any': any});
      };

      $scope.goToSearchFromEvent = function (event) {
        $location.path('/search')
            .search({'title_OR_altTitle_OR_any': event.currentTarget.value});
      };

      $scope.canEdit = function(record) {
        // TODO: take catalog config for harvested records
        if (record && record['geonet:info'] &&
            record['geonet:info'].edit == 'true') {
          return true;
        }
        return false;
      };
      $scope.closeRecord = function() {
        gnMdView.removeLocationUuid();
      };
      $scope.nextPage = function() {
        $scope.$broadcast('nextPage');
      };
      $scope.previousPage = function() {
        $scope.$broadcast('previousPage');
      };

      /**
       * Toggle the list types on the homepage
       * @param  {String} type Type of list selected
       */
      $scope.toggleListType = function(type) {
        $scope.type = type;
      };
      
      $scope.reloadMap = function(){
        recordMap.updateSize();
      }
      
      $scope.infoTabs = {
        lastRecords: {
          title: 'lastRecords',
          titleInfo: '',
          active: true
        },
        preferredRecords: {
          title: 'preferredRecords',
          titleInfo: '',
          active: false
        }};

      // Set the default browse mode for the home page
      $scope.$watch('searchInfo', function (n, o) {
        if (angular.isDefined($scope.searchInfo.facet)) {
          if ($scope.searchInfo.facet['inspireThemes'].length > 0) {
            $scope.browse = 'inspire';
          } else if ($scope.searchInfo.facet['topicCats'].length > 0) {
            $scope.browse = 'topics';
          //} else if ($scope.searchInfo.facet['categories'].length > 0) {
          //  $scope.browse = 'cat';
          }
        }
      });

      $scope.$on('layerAddedFromContext', function(e,l) {
        var md = l.get('md');
        if(md) {
          var linkGroup = md.getLinkGroup(l);
          gnMap.feedLayerWithRelated(l,linkGroup);
        }
      });

      $scope.resultviewFns = {
        addMdLayerToMap: function (link, md) {
          var config = {
            uuid: md ? md.getUuid() : null,
            type:
              link.protocol.indexOf('WMTS') > -1 ? 'wmts' :
              (link.protocol == 'ESRI:REST' ? 'esrirest' : 'wms'),
            url: $filter('gnLocalized')(link.url) || link.url
          };

          var title = link.title;
          var name = link.name;
          if (angular.isObject(link.title)) {
            title = $filter('gnLocalized')(link.title);
          }
          if (angular.isObject(link.name)) {
            name = $filter('gnLocalized')(link.name);
          }

          if (name && name !== '') {
            config.name = name;
            config.group = link.group;
            // Related service return a property title for the name
          } else if (title) {
            config.name = title;
          }

          // if an external viewer is defined, use it here
          if (gnExternalViewer.isEnabled()) {
            gnExternalViewer.viewService({
              id: md ? md.getId() : null,
              uuid: config.uuid
            }, {
              type: config.type,
              url: config.url,
              name: config.name,
              title: title
            });
            return;
          }

          // This is probably only a service
          // Open the add service layer tab
          $location.path('map').search({
            add: encodeURIComponent(angular.toJson([config]))});
          return;
      },
        addAllMdLayersToMap: function (layers, md) {
          angular.forEach(layers, function (layer) {
            $scope.resultviewFns.addMdLayerToMap(layer, md);
          });
        },
        loadMap: function (map, md) {
          gnOwsContextService.loadContextFromUrl(map.url, viewerMap);
        }
      };

      // Share map loading functions
      gnViewerSettings.resultviewFns = $scope.resultviewFns;


      // Manage route at start and on $location change
      // depending on configuration
      if (!$location.path()) {
        var m = gnGlobalSettings.gnCfg.mods;
        $location.path(
          m.home.enabled ? '/home' :
          m.search.enabled ? '/search' :
          m.map.enabled ? '/map' : 'home'
        );
      }
      var setActiveTab = function() {
        $scope.activeTab = $location.path().
        match(/^(\/[a-zA-Z0-9]*)($|\/.*)/)[1];
      };

      setActiveTab();
      $scope.$on('$locationChangeSuccess', setActiveTab);

      var sortConfig = gnSearchSettings.sortBy.split('#');
      angular.extend($scope.searchObj, {
        advancedMode: false,
        from: 1,
        to: 30,
        selectionBucket: 's101',
        viewerMap: viewerMap,
        searchMap: searchMap,
        recordMap: recordMap,
        mapfieldOption: {
          relations: ['within_bbox'],
          autoTriggerSearch: false
        },
        hitsperpageValues: gnSearchSettings.hitsperpageValues,
        filters: gnSearchSettings.filters,
        defaultParams: {
          'facet.q': '',
          resultType: gnSearchSettings.facetsSummaryType || 'details',
          sortBy: sortConfig[0] || 'relevance',
          sortOrder: sortConfig[1] || ''
        },
        params: {
          'facet.q': gnSearchSettings.defaultSearchString || '',
          resultType: gnSearchSettings.facetsSummaryType || 'details',
          sortBy: sortConfig[0] || 'relevance',
          sortOrder: sortConfig[1] || ''
        },
        sortbyValues: gnSearchSettings.sortbyValues
      });
    }])
    .filter('join', function () {
        return function join(array, separator, prop) {
            if (!Array.isArray(array)) {
          return array; // if not array return original - can also throw error
            }
    
            return (!!prop ? array.map(function (item) {
                return item[prop];
            }) : array).join(separator);
        };
    })
    .filter('replace', [function () {
      return function (input, from, to) {
        if(input === undefined) {
          return;
        }
        var regex = new RegExp(from, 'g');
        return input.replace(regex, to);
      };
    }]);
})();
