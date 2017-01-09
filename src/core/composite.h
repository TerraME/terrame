/************************************************************************************
TerraME - a software platform for multiple scale spatially-explicit dynamic modeling.
Copyright (C) 2001-2017 INPE and TerraLAB/UFOP -- www.terrame.org

This code is part of the TerraME framework.
This framework is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

You should have received a copy of the GNU Lesser General Public
License along with this library.

The authors reassure the license terms regarding the warranties.
They specifically disclaim any warranties, including, but not limited to,
the implied warranties of merchantability and fitness for a particular purpose.
The framework provided hereunder is on an "as is" basis, and the authors have no
obligation to provide maintenance, support, updates, enhancements, or modifications.
In no event shall INPE and TerraLAB / UFOP be held liable to any party for direct,
indirect, special, incidental, or consequential damages arising out of the use
of this software and its documentation.
*************************************************************************************/

/**
 * \file composite.h
 * \author Tiago Garcia de Senna Carneiro
 */

#ifndef COMPOSITE_H
#define COMPOSITE_H

#include "bridge.h"
#include <vector>
#include <map>
using namespace std;

// This file defines a generic class to implement the composite design pattern.
// This class generalizes the source code found in the TerraLib library, whose
// authors are Dr Ricardo Cartaxo and Dr Gilberto Camara.

//////////////////////////////////////////////////////////////////////////////////////

/**
 * \brief Defines a generic class to implement the Composite Design Pattern.
 *
 * This class generalizes the source code found in the TerraLib library, whose
 * authors are Dr Ricardo Cartaxo and Dr Gilberto Camara.
 */
template <class TElemnt>
class vectorComposite : public Implementation
{
public:
    typedef TElemnt T;
    typedef int     TKey;
    typedef typename vector<T>::iterator iterator;
    typedef typename vector<T>::reverse_iterator reverse_iterator;

    /// Add a new component
    void add(const T& comp)
    { components_.push_back(comp); }

    /// Remove the i-th component
    bool erase(int i)
    {
        if (components_.size() < i)
            return false;
        return !(components_.erase(components_.begin() + i) == components_.end());
    }

    /// Remove a component
    bool erase(T& comp)
    {
        typename vector<T>::iterator location = components_.begin();
        while (location != components_.end())
        {
            if (comp == *location) {
                components_.erase(location);
                return true;
            }
            location++;
        }
        return false;
    }

    iterator erase(iterator itr) {
        typename vector<T>::iterator location = components_.find(itr->first);
        if (location != components_.end())
        {
            components_.erase(location);
        }
        return itr;
    }

    /// Remove all components
    void clear()
    { components_.clear(); }

    /// Return the composite size
    int size()
    { return components_.size(); }

    /// Return the i-th component
    T& operator [](int i)
    { return components_[i]; }

    /// Find a component and return its iterator
    iterator find(TKey k) {
        vector<TKey >::iterator location = components_.find(k);
        return location;
    }

    /// Check if the composite is empty
    bool empty()
    { return components_.empty(); }

    /// Points to the iterator to the composite first element
    iterator begin(void)
    {
        return components_.begin();
    }

    /// Points to the iterator to the composite last plus one element
    iterator end(void)
    {
        return components_.end();
    }

    /// Points to the reverse_iterator to the composite last plus one element
    reverse_iterator rbegin(void)
    {
        return components_.rbegin();
    }

    /// Points to the reverse_iterator to the composite first element
    reverse_iterator rend(void)
    {
        return components_.rend();
    }

protected:
    vector<T>	components_;
};

//////////////////////////////////////////////////////////////////////////////////////
template <class TIndx, class TElmnt >
class mapComposite : public Implementation
{
public:
    typedef pair<TIndx, TElmnt>  T;
    typedef TIndx				TKey;
    typedef typename map<TKey, TElmnt, less<TKey> >::iterator iterator;
    typedef typename map<TKey, TElmnt, less<TKey> >::reverse_iterator reverse_iterator;

    /// Add a new component
    void add(const T& comp)
    {
        components_.insert(typename map<TKey, TElmnt>::value_type(
        		comp.first, comp.second));
    }

    /// Remove the i-th component
    bool erase(TKey k)
    {
        typename map< TKey, TElmnt, less<TKey> >::iterator location = components_.find(k);
        if (location != components_.end())
        {
            components_.erase(k);
            return true;
        }
        return false;
    }

    /// Remove a component
    bool erase(T& comp)
    {
        typename map< TKey, TElmnt, less<TKey> >::iterator location =
        		components_.find(comp.first);
        if (location != components_.end())
        {
            components_.erase(comp.first);
            return true;
        }
        return false;
    }

    iterator erase(iterator itr) {
        typename map<TKey, TElmnt, less<TKey> >::iterator location =
        		components_.find(itr->first);
        if (location != components_.end())
        {
            components_.erase(location);
        }
        return itr;
    }
    /// Remove all components
    void clear()
    { components_.clear(); }

    /// Return the composite size
    int size()
    { return components_.size(); }

    /// Return the i-th component
    T& operator [](TKey k) {
        typename map<TKey, TElmnt, less<TKey> >::iterator location = components_.find(k);
        return(T&)(*location);
    }

    /// Find a component and return its iterator
    iterator find(TKey k) {
        typename map<TKey, TElmnt, less<TKey> >::iterator location = components_.find(k);
        return location;
    }

    /// Check if the composite is empty
    bool empty()
    { return components_.empty(); }

    /// Points to the iterator to the composite first element
    iterator begin(void)
    {
        return components_.begin();
    }

    /// Points to the iterator to the composite last plus one element
    iterator end(void)
    {
        return components_.end();
    }

    /// Points to the reverse_iterator to the composite last plus one element
    reverse_iterator rbegin(void)
    {
        return components_.rbegin();
    }

    /// Points to the reverse_iterator to the composite first element
    reverse_iterator rend(void)
    {
        return components_.rend();
    }

protected:
    map<TKey, TElmnt, less<TKey> >	components_;
};
//////////////////////////////////////////////////////////////////////////////////////
template <class TIndx, class TElmnt >
class multimapComposite : public Implementation
{
public:
    typedef pair<TIndx, TElmnt>	T;
    typedef TIndx				TKey;
    typedef typename multimap<TKey, TElmnt, less<TKey> >::iterator iterator;
    typedef typename multimap<TKey, TElmnt, less<TKey> >::reverse_iterator reverse_iterator;

    /// Add a new component
    void add(const T& comp)
    {
    	components_.insert(typename multimap<TKey, TElmnt, less<TKey> >::value_type(
    			comp.first, comp.second));
    }

    /// Remove the i-th component
    bool erase(TKey k)
    {
        typename multimap<TKey, TElmnt, less<TKey> >::iterator location =
        		components_.find(k);
        if (location != components_.end())
        {
            components_.erase(k);
            return true;
        }
        return false;
    }

    /// Remove a component
    bool erase(T& comp)
    {
        typename multimap<TKey, TElmnt, less<TKey> >::iterator location =
        		components_.find(comp.first);
        if (location != components_.end())
        {
            components_.erase(comp.first);
            return true;
        }
        return false;
    }

    iterator erase(iterator itr) {
        typename multimap<TKey, TElmnt, less<TKey> >::iterator location =
        		components_.find(itr->first);
        if (location != components_.end())
        {
            components_.erase(location);
        }
        return itr;
    }

    /// Remove all components
    void clear()
    { components_.clear(); }

    /// Return the composite size
    int size()
    { return components_.size(); }

    /// Return the i-th component
    T& operator [](TKey k) {
        typename multimap<TKey, TElmnt, less<TKey> >::iterator location =
        		components_.find(k);
        return(T&)(*location);
    }

    /// Find a component and return its iterator
    iterator find(TKey k) {
        typename multimap<TKey, TElmnt, less<TKey> >::iterator location =
        		components_.find(k);
        return location;
    }

    /// Check if the composite is empty
    bool empty()
    { return components_.empty(); }

    /// Points to the iterator to the composite first element
    iterator begin(void)
    {
        return components_.begin();
    }

    /// Points to the iterator to the composite last plus one element
    iterator end(void)
    {
        return components_.end();
    }

    /// Points to the reverse_iterator to the composite last plus one element
    reverse_iterator rbegin(void)
    {
        return components_.rbegin();
    }

    /// Points to the reverse_iterator to the composite first element
    reverse_iterator rend(void)
    {
        return components_.rend();
    }

protected:
    multimap<TKey, TElmnt, less<TKey> >	components_;
};
//////////////////////////////////////////////////////////////////////////////////////
template < class CpstImpl >
class CompositeInterface : public Interface< CpstImpl >
{
public:
    typedef typename CpstImpl::T      TElemnt;      // Element type
    typedef typename CpstImpl::TKey   Indx;         // Element index
    typedef typename CpstImpl::iterator iterator;   // Element iterator
    typedef typename CpstImpl::reverse_iterator reverse_iterator; // Element reverse_iterator

    /// Add a new component
    void add(const TElemnt& comp) {(CompositeInterface::pImpl_)->add(comp); }

    /// Remove the i-th component
    bool erase(Indx i) { return	(CompositeInterface::pImpl_)->erase(i); }

    /// Remove a component
    bool erase(TElemnt& /*comp*/) { return false; }//return(CompositeInterface::pImpl_)->erase(comp); }

    iterator erase(iterator itr) { return(CompositeInterface::pImpl_)->erase(itr); }

    /// Remove all components
    void clear() {(CompositeInterface::pImpl_)->clear(); }

    /// Return the composite size
    int size() { return(CompositeInterface::pImpl_)->size(); }

    /// Return the i-th component
    TElemnt& operator [](Indx i) { return(*(CompositeInterface::pImpl_))[i]; }

    /// Return the i-th component
    iterator find(Indx i) { return(CompositeInterface::pImpl_)->find(i); }

    /// Check if the composite is empty
    bool empty()	{ return(CompositeInterface::pImpl_)->empty(); }

    /// Points to the iterator to the composite first element
    iterator begin(void) { return(CompositeInterface::pImpl_)->begin(); }

    /// Points to the iterator to the composite last plus one element
    iterator end(void) { return(CompositeInterface::pImpl_)->end(); }

    /// Points to the reverse_iterator to the composite last plus one element
    reverse_iterator rbegin(void) { return(CompositeInterface::pImpl_)->rbegin(); }

    /// Points to the reverse_iterator to the composite first element
    reverse_iterator rend(void) { return(CompositeInterface::pImpl_)->rend(); }

    // Operator ==
    // A composite is equal to another if and only if they have the same elements

    /**
         * \brief Operator ==
         *
         * A composite is equal to another if and only if they have the same elements.
         */
    bool operator==(CompositeInterface& comp)
    {
        int size1 = size();
        int size2 = comp.size();

        if (size1 > size2 || size1 < size2) return false;

        iterator theIterator;
        typename CompositeInterface::iterator iterator;
        theIterator =(CompositeInterface::pImpl_)->begin();
        while (theIterator !=(CompositeInterface::pImpl_)->end())
        {
            iterator = comp.begin();
            while (iterator != comp.end())
            {
                if (theIterator == iterator) return false;
                iterator++;
                theIterator++;
            }
        }

        return true;
    }
};

#endif
