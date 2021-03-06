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


  goog.provide('gn_search_controller');


  goog.require('gn_catalog_service');
  goog.require('gn_searchsuggestion_service');
  goog.require('gn_static_pages');
  goog.require('gn_usersearches');

  var module = angular.module('gn_search_controller', [
    'ui.bootstrap.typeahead',
    'gn_searchsuggestion_service',
    'gn_catalog_service',
    'gn_static_pages',
    'gn_usersearches'
  ]);

  /**
   * Main search controller attached to the first element of the
   * included html file from the base-layout.xsl output.
   */
  module.controller('GnSearchController', [
    '$scope',
    '$q',
    '$http',
    'suggestService',
    'gnAlertService',
    'gnSearchSettings',
    'gnGlobalSettings',
    'gnConfig',
    'orderByFilter',
    function($scope, $q, $http, suggestService, gnAlertService,
             gnSearchSettings, gnGlobalSettings, gnConfig, orderByFilter) {

      /** Object to be shared through directives and controllers */
      $scope.searchObj = {
        params: {},
        permalink: true,
        sortbyValues: gnSearchSettings.sortbyValues,
        sortbyDefault: gnSearchSettings.sortbyDefault,
        hitsperpageValues: gnSearchSettings.hitsperpageValues
      };

      $scope.isUserFeedbackEnabled = false;

      statusSystemRating = gnConfig[gnConfig.key.isRatingUserFeedbackEnabled];
      if (statusSystemRating == 'advanced') {
        $scope.isUserFeedbackEnabled = true;
      }

      $scope.isUserSearchesEnabled = gnGlobalSettings.gnCfg.mods.search.usersearches.enabled;
      $scope.displayFeaturedSearchesPanel =
        gnGlobalSettings.gnCfg.mods.search.usersearches.displayFeaturedSearchesPanel;

      $scope.ise  = false;

      /** Facets configuration */
      $scope.facetsSummaryType = gnSearchSettings.facetsSummaryType;

      /* Pagination configuration */
      $scope.paginationInfo = gnSearchSettings.paginationInfo;

      /* Default result view template */
      $scope.resultTemplate = gnSearchSettings.resultTemplate ||
          gnSearchSettings.resultViewTpls[0].tplUrl;
      /* Default advanced search form template */
      $scope.advancedSearchTemplate = gnSearchSettings.advancedSearchTemplate ||
        '../../catalog/views/default/templates/advancedSearchForm/defaultAdvancedSearchForm.html';

      $scope.getAnySuggestions = function(val) {
        return suggestService.getAnySuggestions(val);
      };
      $scope.isRecordIndexing = false;
      checkIsIndexing();
      function checkIsIndexing() {
        // Check if indexing
        $http.get('../api/site/indexing').then(function(res) {
              $scope.isRecordIndexing = res.data;
        });
      }

      $scope.checkIndexStatus = function(){
        checkIsIndexing();       
        $scope.$broadcast('resetSearch', $scope.searchObj.params);          
      }
      $scope.keywordsOptions = {
        mode: 'remote',
        remote: {
          url: suggestService.getUrl('QUERY', 'keyword', 'STARTSWITHFIRST'),
          filter: suggestService.bhFilter,
          wildcard: 'QUERY'
        }
      };

      $scope.getAuthorSuggestions = function(val) {
        return suggestService.getAuthorSuggestions(val);
      };

      $scope.orgNameOptions = {
        mode: 'remote',
        remote: {
          url: suggestService.getUrl('QUERY', 'orgName', 'STARTSWITHFIRST'),
          filter: suggestService.bhFilter,
          wildcard: 'QUERY'
        }
      };

      $scope.userOptions = {
        mode: 'prefetch',
        promise: (function() {
          var defer = $q.defer();
          $http.get('../api/users', {cache: true}).
              success(function(data) {
                var res = [];
                for (var i = 0; i < data.length; i++) {
                  res.push({
                    id: data[i].id,
                    name: data[i].name + ' ' + data[i].surname + ' (' + data[i].username + ')'
                  });
                }
                defer.resolve(res);
              });
          return defer.promise;
        })()
      };
  
      $scope.typeOptions = [{
		  id: 'n',
		  label: 'Metadata'
		}, {
		  id: 'y',
		  label: 'Template'
	  }];

      $scope.statusOptions = [];
	  
	  $http.get('../api/status', {cache: true}).
		  success(function (data){
		  $scope.statusOptions = data;
	  });
	  
      $scope.categoriesOptions = {
        mode: 'prefetch',
        promise: (function() {
          var defer = $q.defer();
          $http.get('../api/tags', {cache: true}).
              success(function(data) {
                var res = [];
                for (var i = 0; i < data.length; i++) {
                  res.push({
                    id: data[i].name,
                    name: data[i].label[$scope.lang]
                  });
                }
                res = orderByFilter(res,'name',false);
                defer.resolve(res);
              });
          return defer.promise;
        })()
      };

      $scope.sourcesOptions = {
        mode: 'prefetch',
        promise: (function() {
          var defer = $q.defer();
          $http.get('../api/sources', {cache: true}).
              success(function(a) {
                var res = [];
                for (var i = 0; i < a.length; i++) {
                  res.push({
                    id: a[i].id,
                    name: a[i].name
                  });
                }
                defer.resolve(res);
              });
          return defer.promise;
        })()
      };

      $scope.obj = {
   		   xpath: ''
   	   };
      $scope.stat = {
   		   searching: false,
   		   background:false
   	   };
      $scope.triggerXPathSearch = function(){
          $scope.stat.searching = true;
          $http.get('../api/records/search/status').success(function(data){
            if (data) {
              $scope.stat.searching = false;
              $scope.stat.background = true;
              console.log("Another Xpath search executing in the backgorund");
            }else{
              angular.extend($scope.obj, $scope.searchObj.params);
              $http.post('../api/records/search/xpath',  $scope.obj);
              checkIsSearching();
            }
          })
       };
   	  
   	   function checkIsSearching(){
   		    
   			// Check if completed
   			return $http.get('../api/records/search/status').
   				success(function(data) {
   				  if (data) {
   					$timeout(checkIsSearching, 1000);
   				  }else{
   					  $http.get('../api/records/search/xpath',{}).success(function(data){
   						  $scope.stat.searching = false;
   						  var eCatIds = {
   							  eCatId : ''
   						  }
   						  
   						  eCatIds.eCatId = (data.length == 0) ? 'xxxx' : data.slice(0, 1000).join(',');
   						  
   						  angular.extend($scope.searchObj.params, eCatIds);
   						  $scope.$broadcast('search');
   						  
   					  })
   				  }
   				});
   		  };
       
         $scope.homeSearch = function(){
           var anytext = {
             title_OR_altTitle_OR_any : $scope.searchObj.params.title_OR_altTitle_OR_any
           }           
          $scope.$broadcast('resetSearch', anytext);             
        }
        $scope.searchHomePageItem = function(type){
        var param;
        if(type === 'latest_publication'){
          var today = moment();
          var month = today.format('MM');
          var year = today.format('YYYY');
          
          var fromDate = moment().subtract(30, 'days');
          var fromMonth = fromDate.format('MM');
          var fromYear = fromDate.format('YYYY');
          var dateFrom = fromYear + '-' + fromMonth + '-' + fromDate.daysInMonth();
          var dateTo = year + '-' + month + '-' + today.daysInMonth();
          param = {
            publicationDateFrom: dateFrom,
            publicationDateTo: dateTo
          }
        }
        if(type === 'ga_publication'){
          param = {
            'facet.q' : 'keyword/GA Publication'
          }
        }
        if(type === 'edu_products'){
          param = {
            'facet.q' : 'keyword/Educational Product'
          }
        }        
        $scope.$broadcast('resetSearch', param);        
      }
      
      /**
       * Keep a reference on main cat scope
       * @return {*}
       */
      $scope.getCatScope = function() {return $scope};
    }]);
})();
