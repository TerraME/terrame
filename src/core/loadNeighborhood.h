#ifndef TME_NO_TERRALIB

#if ! defined(LOAD_NEIGHBORHOOD_H) 
#define LOAD_NEIGHBORHOOD_H

#include <TeProgress.h>

template<typename set>
bool loadDefaultGPM(TeDatabase* db, const int& themeId, TeGeneralizedProxMatrix<set>* &gpm, 
                    TeGPMConstructionStrategy& strategy, double& max_distance, double& num_neighbours)
{
    if(!db)
        return false;

    TeDatabasePortal* portal = db->getPortal();
    if(!portal)
        return false;

    //load the table name
    string sql = " SELECT gpm_id, neighbours_table, weight_strategy, weight_norm, ";
    sql += " weight_a, weight_b, weight_c, weight_factor, weight_dist_raio, ";
    sql += " weigth_max_local_dist, construction_strategy, const_max_distance, const_num_neighbours FROM te_gpm ";
    sql += " WHERE theme_id1 = "+ Te2String(themeId) +" AND gpm_default = 1";
    if(!portal->query(sql) || !portal->fetchRow())
    {
        delete portal;
        return false;
    }

    string table = portal->getData(1);
    int gpmId = portal->getInt(0);
    int weightStrategy = portal->getInt(2);

    //load weight strategy
    TeProxMatrixWeightsStrategy* ws = 0;
    if((TeGPMWeightsStrategy)weightStrategy == TeNoWeightsStrategy)
        ws = new TeProxMatrixNoWeightsStrategy((bool)portal->getInt(3));

    else if((TeGPMWeightsStrategy)weightStrategy == TeInverseDistanceStrategy)
        ws = new TeProxMatrixInverseDistanceStrategy (portal->getDouble(4), portal->getDouble(5),
                                                      portal->getDouble(6), portal->getDouble(7), (bool)portal->getInt(3));

    else if((TeGPMWeightsStrategy)weightStrategy == TeSquaredInverseDistStrategy)
        ws = new TeProxMatrixSquaredInverseDistanceStrategy (portal->getDouble(4), portal->getDouble(5),
                                                             portal->getDouble(6), portal->getDouble(7), (bool)portal->getInt(3));

    else if((TeGPMWeightsStrategy)weightStrategy == TeConnectionStrenghtStrategy)
        ws = new TeProxMatrixConnectionStrenghtStrategy(portal->getDouble(8), portal->getDouble(9),
                                                        portal->getDouble(7), (bool)portal->getInt(3));

    portal->freeResult();

    sql= " SELECT count(*) FROM "+ table;
    if(!portal->query(sql))
    {
        delete portal;
        return false;
    }
    int numSteps = atoi(portal->getData(0));
    int step = 0;
    if(TeProgress::instance())
        TeProgress::instance()->setTotalSteps(numSteps);

    portal->freeResult();

    sql= " SELECT object_id1, object_id2, centroid_distance, weight, ";
    sql += " slice, order_neig, borders_length, net_objects_distance, ";
    sql += " net_minimum_path FROM "+ table;
    if(!portal->query(sql))
    {
        delete portal;
        return false;
    }

    TeProxMatrixImplementation* impl = TeProxMatrixAbstractFactory::MakeConcreteImplementation();
    while(portal->fetchRow())
    {
        TeProxMatrixAttributes attr(portal->getDouble(3), portal->getInt(4),
                                    portal->getInt(5),  portal->getDouble(2), portal->getDouble(6),
                                    portal->getDouble(7), portal->getDouble(8));

        impl->connectObjects (string(portal->getData(0)), string(portal->getData(1)), attr);

        if(TeProgress::instance())
        {
            if (TeProgress::instance()->wasCancelled())
            {
                TeProgress::instance()->reset();
                delete portal;
                return false;
            }
            else
                TeProgress::instance()->setProgress(step);
        }
        ++step;
    }
    if (TeProgress::instance())
        TeProgress::instance()->reset();

    gpm = new TeGeneralizedProxMatrix<set>(gpmId, table, impl, ws);

    // I was trying to use the API GPM, but it is difficult to build a GPM from
    // the database, lack the API methods to load the metadata as building strategies,
    // slicing strategy etc. I gave up and put methods parameters by reference to return
    // the metadata that I need

    //load  and set the construction strategy parameters
    //TeProxMatrixConstructionStrategy<set>* constStrategy;
    //int strategy = portal->getInt(9);
    //if((TeGPMConstructionStrategy) strategy == TeAdjacencyStrategy)  //adjacency
    //{
    //	constStrategy = TeProxMatrixLocalAdjacencyStrategy();
    //}
    //else if((TeGPMConstructionStrategy) strategy == TeDistanceStrategy)  //distance
    //{
    //	constStrategy = TeProxMatrixLocalDistanceStrategy();
    //}
    //else if((TeGPMConstructionStrategy) strategy == TeNearestNeighboursStrategy)  //nn
    //{
    //	constStrategy =	TeProxMatrixNearestNeighbourStrategy();
    //}
    //gpm = new TeGeneralizedProxMatrix (constStrategy,  ws, 0, TeGraphBreymann, gpmId, false,  table, 1);
    //gpm->impl_strategy_ = impl;
    //gpm->setCurrentConstructionStrategy(constStrategy);
    //constStrategy->
    //TeProxMatrixConstructionParams* constParams = new TeProxMatrixConstructionParams();
    strategy = (TeGPMConstructionStrategy)portal->getInt(10);
    max_distance = portal->getDouble(11);
    num_neighbours = portal->getInt(12);

    delete portal;
    return true;
}

template<typename set>
bool loadGPM(TeDatabase* db, const int& themeId, TeGeneralizedProxMatrix<set>* &gpm, string& gpmID,
             TeGPMConstructionStrategy& strategy, double& max_distance, double& num_neighbours)
{
    if(!db)
        return false;

    TeDatabasePortal* portal = db->getPortal();
    if(!portal)
        return false;

    //load the table name
    string sql = " SELECT gpm_id, neighbours_table, weight_strategy, weight_norm, ";
    sql += " weight_a, weight_b, weight_c, weight_factor, weight_dist_raio, ";
    sql += " weigth_max_local_dist, construction_strategy, const_max_distance, const_num_neighbours FROM te_gpm ";
    sql += " WHERE theme_id1 = "+ Te2String(themeId) +" AND gpm_id = "+ gpmID;
    if(!portal->query(sql) || !portal->fetchRow())
    {
        delete portal;
        return false;
    }

    string table = portal->getData(1);
    int gpmId = portal->getInt(0);
    int weightStrategy = portal->getInt(2);

    //load weight strategy
    TeProxMatrixWeightsStrategy* ws = 0;
    if((TeGPMWeightsStrategy)weightStrategy == TeNoWeightsStrategy)
        ws = new TeProxMatrixNoWeightsStrategy((bool)portal->getInt(3));

    else if((TeGPMWeightsStrategy)weightStrategy == TeInverseDistanceStrategy)
        ws = new TeProxMatrixInverseDistanceStrategy (portal->getDouble(4), portal->getDouble(5),
                                                      portal->getDouble(6), portal->getDouble(7), (bool)portal->getInt(3));

    else if((TeGPMWeightsStrategy)weightStrategy == TeSquaredInverseDistStrategy)
        ws = new TeProxMatrixSquaredInverseDistanceStrategy (portal->getDouble(4), portal->getDouble(5),
                                                             portal->getDouble(6), portal->getDouble(7), (bool)portal->getInt(3));

    else if((TeGPMWeightsStrategy)weightStrategy == TeConnectionStrenghtStrategy)
        ws = new TeProxMatrixConnectionStrenghtStrategy(portal->getDouble(8), portal->getDouble(9),
                                                        portal->getDouble(7), (bool)portal->getInt(3));

    portal->freeResult();

    sql= " SELECT count(*) FROM "+ table;
    if(!portal->query(sql))
    {
        delete portal;
        return false;
    }
    int numSteps = atoi(portal->getData(0));
    int step = 0;
    if(TeProgress::instance())
        TeProgress::instance()->setTotalSteps(numSteps);

    portal->freeResult();

    sql= " SELECT object_id1, object_id2, centroid_distance, weight, ";
    sql += " slice, order_neig, borders_length, net_objects_distance, ";
    sql += " net_minimum_path FROM "+ table;
    if(!portal->query(sql))
    {
        delete portal;
        return false;
    }

    TeProxMatrixImplementation* impl = TeProxMatrixAbstractFactory::MakeConcreteImplementation();
    while(portal->fetchRow())
    {
        TeProxMatrixAttributes attr(portal->getDouble(3), portal->getInt(4),
                                    portal->getInt(5),  portal->getDouble(2), portal->getDouble(6),
                                    portal->getDouble(7), portal->getDouble(8));

        impl->connectObjects (string(portal->getData(0)), string(portal->getData(1)), attr);

        if(TeProgress::instance())
        {
            if (TeProgress::instance()->wasCancelled())
            {
                TeProgress::instance()->reset();
                delete portal;
                return false;
            }
            else
                TeProgress::instance()->setProgress(step);
        }
        ++step;
    }
    if (TeProgress::instance())
        TeProgress::instance()->reset();

    gpm = new TeGeneralizedProxMatrix<set>(gpmId, table, impl, ws);

    // I was trying to use the API GPM, but it is difficult to build a GPM from
    // the database, lack the API methods to load the metadata as building strategies,
    // slicing strategy etc. I gave up and put methods parameters by reference to return
    // the metadata that I need

    //load  and set the construction strategy parameters
    //TeProxMatrixConstructionStrategy<set>* constStrategy;
    //int strategy = portal->getInt(9);
    //if((TeGPMConstructionStrategy) strategy == TeAdjacencyStrategy)  //adjacency
    //{
    //	constStrategy = TeProxMatrixLocalAdjacencyStrategy();
    //}
    //else if((TeGPMConstructionStrategy) strategy == TeDistanceStrategy)  //distance
    //{
    //	constStrategy = TeProxMatrixLocalDistanceStrategy();
    //}
    //else if((TeGPMConstructionStrategy) strategy == TeNearestNeighboursStrategy)  //nn
    //{
    //	constStrategy =	TeProxMatrixNearestNeighbourStrategy();
    //}
    //gpm = new TeGeneralizedProxMatrix (constStrategy,  ws, 0, TeGraphBreymann, gpmId, false,  table, 1);
    //gpm->impl_strategy_ = impl;
    //gpm->setCurrentConstructionStrategy(constStrategy);
    //constStrategy->
    //TeProxMatrixConstructionParams* constParams = new TeProxMatrixConstructionParams();
    strategy = (TeGPMConstructionStrategy)portal->getInt(10);
    max_distance = portal->getDouble(11);
    num_neighbours = portal->getInt(12);

    delete portal;
    return true;
}

#endif

#endif // TME_NO_TERRALIB
